class Item < ActiveRecord::Base

  has_many :acks

  before_save :extract_path

  def self.calculate_all
    Item.all.each do |item|
      item.refresh_from_acks!
    end
  end

  def refresh_from_acks!
    self.reset
    self.acks.all.each do |ack|
      self.apply_score(ack.score)
    end
    self.save!
  end

  def reset
    self.total_count = 0
    self.positive_count = 0
    self.negative_count = 0
    self.neutral_count = 0
    self.positive_score = 0
    self.negative_score = 0
    self.controversiality = 0
  end

  def apply_score(score)
    self.total_count += 1
    if score > 0
      self.positive_count += 1
    elsif score < 0
      self.negative_count += 1
    else
      self.neutral_count += 1
    end
    self.positive_score += score if score > 0
    self.negative_score -= score if score < 0
    self.controversiality = [self.positive_count, self.negative_count].min
  end

  def self.pick(already_picked, resultset, number, random)
    picked = []
    until resultset.empty? || picked.size == number
      pos = random ? rand(resultset.length) : 0
      item = resultset.delete_at(pos)
      picked << item unless already_picked.include?(item.id)
    end
    picked
  end

  def self.by_field(path, segment, sample_size, identity)
    scope = Item.scoped.where(:path => path).order("#{segment[:field]} #{segment[:order]} NULLS LAST").limit(sample_size)

    unless identity.nil? # if identity is given, exclude every items that this identity has voted for already
      scope = scope
      .joins("LEFT OUTER JOIN acks on acks.item_id = items.id and acks.identity=#{identity}")
      .where("acks.id IS NULL")
    end
    #raise scope.to_sql
    scope
  end

  def self.combine_resultsets(path, params)
    picked = []
    remaining = []
    sampled = params.segments.map do |segment|

      sample_size_percent = segment[:sample_size] || segment[:percent]
      total = Item.count
      sample_row_num = (total * 0.01 * sample_size_percent).ceil # how many rows to pick randomly from
      sample_row_num = params.limit if sample_row_num < params.limit # always try to return <limit> items

      results = Item.by_field(path, segment, sample_row_num, params.identity_id)
      share_of_total = params.limit * segment[:percent] * 0.01

      sampled = Item.pick(picked, results, share_of_total.ceil, params.shuffle)

      picked |= sampled.map(&:id)
      remaining.concat results
      sampled
    end
    sampled.flatten!

    diff = (params.limit - sampled.size).to_i
    if diff > 0
      sampled |= Item.pick(picked, remaining, diff, params.shuffle)
    end
    sampled.shuffle! if params.shuffle
    sampled
  end

  def extract_path
    klass, self.path, oid = Pebblebed::Uid.parse external_uid
  end

end

require "pp"
class Item < ActiveRecord::Base

  has_many :acks

  before_save :extract_path

  CONTRO_LIMIT = 4.freeze


  def self.calculate_all
    Item.all.each do |item|
      item.refresh_from_acks!
    end
  end

  def refresh_from_acks!
    self.reset
    self.acks.all.each do |ack|
      self.apply_score(ack.score, false)
    end
    self.controversiality = self.calculate_controversiality
    self.save!
  end

  def reset
    self.total_count = 0
    self.positive_count = 0
    self.negative_count = 0
    self.neutral_count = 0
    self.positive_score = 0
    self.negative_score = 0
    self.controversiality = nil
  end

  def apply_score(score, should_calculate_controversiality = true)
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
    self.controversiality = self.calculate_controversiality if should_calculate_controversiality
  end

  def calculate_controversiality
    contro = nil
    if self.positive_count + self.negative_count > Item::CONTRO_LIMIT
      counts = [self.positive_count.to_f, self.negative_count.to_f]
      contro = counts.min / counts.max
    end
    contro
  end

  def self.pick_random(already_picked, resultset, number)
    picked = []
    until resultset.empty? || picked.size == number
      item = resultset.delete_at(rand(resultset.length))
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

  def self.combine_resultsets(path, segments, limit, identity_id)
    picked = []
    remaining = []
    sampled = segments.map do |segment|

      sample_size_percent = segment[:sample_size] || segment[:percent]
      total = Item.count
      sample_row_num = (total * 0.01 * sample_size_percent).ceil # how many rows to pick randomly from
      sample_row_num = limit if sample_row_num < limit # always try to return <limit> items

      results = Item.by_field(path, segment, sample_row_num, identity_id)
      share_of_total = limit * segment[:percent] * 0.01

      sampled = Item.pick_random(picked, results, share_of_total.ceil)
      picked |= sampled.map(&:id)
      remaining.concat results
      sampled
    end
    sampled.flatten!

    diff = (limit - sampled.size).to_i
    if diff > 0
      sampled |= Item.pick_random(picked, remaining, diff)
    end
    sampled.shuffle!
  end

  def extract_path
    klass, self.path, oid = Pebblebed::Uid.parse external_uid
  end

end

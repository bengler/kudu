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
    scope = Item.scoped.where(:path => path).order("#{segment.field} #{segment.order} NULLS LAST").limit(sample_size)
    unless identity.nil?
      scope = scope
      .joins("LEFT OUTER JOIN acks on acks.item_id = items.id and acks.identity=#{identity}")
      .where("acks.id IS NULL")
    end
    scope
  end

  def self.combine_resultsets(path, options, identity)
    picked = []
    remaining = []
    sampled = options.segments.map do |segment|
      total = Item.count
      sample_size = (total * 0.01 * Float(segment.percent)).ceil

      results = Item.by_field(path, segment, sample_size, identity)
      share_of_total = Float(options.limit) * Float(segment.percent) * 0.01

      sampled = Item.pick_random(picked, results, share_of_total.ceil)
      picked |= sampled.map(&:id)
      remaining.concat results
      sampled
    end

    diff = Integer(options.limit) - sampled.size
    if diff > 0
      sampled |= Item.pick_random(picked, remaining, diff)
    end
    sampled.shuffle!
  end

  def extract_path
    klass, self.path, oid = Pebblebed::Uid.parse external_uid
  end

end

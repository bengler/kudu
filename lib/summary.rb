
class Summary

  CONTRO_LIMIT = 4.freeze

  attr_accessor :external_uid, :total_ack_count, :positive_ack_count, :negative_ack_count, :neutral_ack_count,
                    :positive_score, :negative_score, :controversiality

  # Class methods
  def self.calculate_all
    Ack.select("DISTINCT(external_uid)").each do |ack|
      summary = Summary.find_or_create_by_external_uid(ack.external_uid)
      summary.recalculate!
    end
  end

  # Redis ActiveRecord look-a-likes, maybe refactor these out later
  def self.find_by_external_uid(external_uid)
    redis_result = $redis.get "summary-#{external_uid}"
    if redis_result
      Marshal.load(redis_result)
    else
      nil
    end
  end

  def self.find_all_by_external_uids(external_uids)
    res = []
    external_uids.each do |external_uid|
      res << find_by_external_uid(external_uid)
    end
    res
  end

  def self.find_or_create_by_external_uid(external_uid)
    summary = Summary.find_by_external_uid(external_uid)
    unless summary
      summary = Summary.new(external_uid)
    end
    summary
  end

  # Instance methods
  def initialize(external_uid)
    self.external_uid = external_uid
    self.reset!
  end

  def acks
    Ack.find_all_by_external_uid(self.external_uid)
  end

  def recalculate!
    reset!
    acks.each do |ack|
      apply_score ack.score
    end
    save!
  end

  def apply_score(score)
    self.total_ack_count += 1
    if score > 0
      self.positive_ack_count += 1
    elsif score < 0
      self.negative_ack_count += 1
    else
      self.neutral_ack_count += 1
    end
    self.positive_score += score if score > 0
    self.negative_score -= score if score < 0
    self.controversiality = self.calculate_controversiality
  end

  # Methods kept protected for internal consistency
  def reset!
    self.total_ack_count = 0
    self.positive_ack_count = 0
    self.negative_ack_count = 0
    self.neutral_ack_count = 0
    self.positive_score = 0
    self.negative_score = 0
    self.controversiality = nil
  end

  def calculate_controversiality
    contro = nil
    if self.positive_ack_count + self.negative_ack_count > Summary::CONTRO_LIMIT
      counts = [self.positive_ack_count.to_f, self.negative_ack_count.to_f]
      contro = counts.min / counts.max
    end
    contro
  end

  protected

  def save!
    $redis.set "summary-#{self.external_uid}", Marshal.dump(self)
  end

end

class Item < ActiveRecord::Base

  has_many :acks

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

end

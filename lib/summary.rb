class Summary < ActiveRecord::Base

  has_many :acks

  scope :highscoring, lambda {|limit| order("count desc").limit(limit)}
  scope :in_collection, lambda {|collection| where(:collection => collection)}


  def apply_score!(score)
    self.count += 1
    self.positive += score if score > 0
    self.negative -= score if score < 0
    # make this smarter: self.contro = [self.negative, self.positive].min / [self.negative, self.positive].max
    self.save
  end

  def rollback_score!(score)
    self.count -= 1
    self.positive -= score if score > 0
    self.negative += score if score < 0
    # handle contro
    self.save
  end

end

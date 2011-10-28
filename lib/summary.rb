class Summary < ActiveRecord::Base

  scope :highscoring, lambda {|limit| order("count desc").limit(limit)}
  scope :in_collection, lambda {|collection| where(:collection => collection)}


  def recalculate!(score)
    self.count += 1
    self.negative += score if score < 0
    self.positive += score if score > 0
    # make this smarter: self.contro = [self.negative, self.positive].min / [self.negative, self.positive].max
    self.save
  end

end

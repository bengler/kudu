class Summary < ActiveRecord::Base

  scope :highscoring, lambda {|limit| order("count desc").limit(limit)}
  scope :in_collection, lambda {|collection| where(:collection => collection)}


end

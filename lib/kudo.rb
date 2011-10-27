class Kudo < ActiveRecord::Base

  scope :recent, lambda {|count| order("updated_at desc").limit(count)}


end

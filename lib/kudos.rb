class Kudos < ActiveRecord::Base

  include Tire::Model::Search
  include Tire::Model::Callbacks

  scope :recent, lambda {|count| order("updated_at desc").limit(count)}


end

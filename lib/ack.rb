class Ack < ActiveRecord::Base

  scope :recent, lambda {|count| order("updated_at desc").limit(count)}

  before_save :update_summary


  def update_summary
    summary = Summary.find_or_create_by_external_uid(self.external_uid)
    summary.recalculate!(self.score)
  end

end

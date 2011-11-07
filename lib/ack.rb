class Ack < ActiveRecord::Base

  validates_presence_of :score, :external_uid, :identity

  scope :recent, lambda {|count| order("updated_at desc").limit(count)}

  after_save :create_or_update_summary
  after_destroy :create_or_update_summary # using create_* to ensure redis knows about this summary

  def create_or_update_summary
    summary = Summary.find_or_create_by_external_uid(self.external_uid)
    summary.recalculate!
  end

  def self.create_or_update(uid, identity, options = {})
    ack = Ack.find_by_external_uid_and_identity(uid, identity)
    ack ||= Ack.new(:external_uid => uid, :identity => identity)
    ack.attributes = options
    ack.save!
    ack
  end

  def summary
    Summary.find_by_external_uid(self.external_uid)
  end

end

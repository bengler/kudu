class Ack < ActiveRecord::Base

  belongs_to :summary

  validates_presence_of :score, :external_uid, :identity

  scope :recent, lambda {|count| order("updated_at desc").limit(count)}

  before_save :create_or_update_summary
  after_destroy { |record| record.summary.rollback_score!(record.score) }

  def create_or_update_summary
    sumry = Summary.find_or_create_by_external_uid(self.external_uid)
    sumry.apply_score!(self.score)
    self.summary = sumry
  end


  def self.create_or_update(uid, identity, options = {})
    ack = Ack.find_by_external_uid_and_identity(uid, identity)
    ack ||= Ack.new(:external_uid => uid, :identity => identity)
    ack.attributes = options
    ack.save!
    ack
  end

end

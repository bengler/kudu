class Ack < ActiveRecord::Base

  belongs_to :summary

  validates_presence_of :score, :external_uid, :identity

  scope :recent, lambda {|count| order("updated_at desc").limit(count)}

  after_save :create_or_update_summary
  after_destroy { |record| record.summary.refresh_from_acks! }

  def create_or_update_summary
    sumry = Summary.find_or_create_by_external_uid(self.external_uid)
    if sumry.new_record?
      sumry.apply_score(self.score)
    else
      sumry.refresh_from_acks!
    end
    sumry.save
    unless self.summary
      self.summary_id = sumry.id
      self.save
    end
  end


  def self.create_or_update(uid, identity, options = {})
    ack = Ack.find_by_external_uid_and_identity(uid, identity)
    ack ||= Ack.new(:external_uid => uid, :identity => identity)
    ack.attributes = options
    ack.save!
    ack
  end

end

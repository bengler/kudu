class Ack < ActiveRecord::Base

  belongs_to :score

  validates_presence_of :value, :identity

  scope :recent, lambda {|count| order("updated_at desc").limit(count)}

  after_save :create_or_update_score
  after_destroy { |ack| ack.score.refresh_from_acks! }

  def create_or_update_score
    score.refresh_from_acks!
  end


  def self.create_or_update(score, identity, options = {})
    ack = Ack.find_by_score_id_and_identity(score.id, identity)
    ack ||= Ack.new(:score_id => score.id, :identity => identity)
    ack.attributes = options
    ack
  end

end

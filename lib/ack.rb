class Ack < ActiveRecord::Base

  belongs_to :item

  validates_presence_of :score, :identity

  scope :recent, lambda {|count| order("updated_at desc").limit(count)}

  after_save :create_or_update_item
  after_destroy { |ack| ack.item.refresh_from_acks! }

  def create_or_update_item
    item.refresh_from_acks!
  end


  def self.create_or_update(item, identity, options = {})
    ack = Ack.find_by_item_id_and_identity(item.id, identity)
    ack ||= Ack.new(:item_id => item.id, :identity => identity)
    ack.attributes = options
    ack
  end

end

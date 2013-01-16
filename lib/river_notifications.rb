require 'pebblebed'
require_relative 'ack'

class RiverNotifications < ActiveRecord::Observer
  observe :ack

  def self.river
    @river ||= Pebblebed::River.new
  end

  def after_create(ack)
    publish(ack, :create)
  end

  def after_update(ack)
    publish(ack, :update)
  end

  def after_destroy(ack)
    publish(ack, :delete)
  end

  def publish(ack, event)
    self.class.river.publish(:event => event, :uid => ack.uid, :attributes => ack.attributes_for_export)
  end

end

class AddProfileToAck < ActiveRecord::Migration
  def self.up
    add_column :acks, :profile, :text
  end

  def self.down
    add_column :acks, :profile, :text
  end
end

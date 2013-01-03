class AddProfileToAck < ActiveRecord::Migration
  def self.up
    add_column :acks, :created_by_profile, :text
  end

  def self.down
    remove_column :acks, :created_by_profile
  end
end

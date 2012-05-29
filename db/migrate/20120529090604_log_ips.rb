class LogIps < ActiveRecord::Migration
  def self.up
    add_column :acks, :ip, :text
  end

  def self.down
    remove_column :acks, :ip
  end
end

class AddIndexToKind < ActiveRecord::Migration
  def self.up
    add_index :acks, :kind
  end

  def self.down
    remove_index :acks, :kind
  end
end

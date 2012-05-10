class AddKindToAcks < ActiveRecord::Migration
  def self.up
    add_column :acks, :kind, :text
  end

  def self.down
    remove_column :acks, :kind
  end
end

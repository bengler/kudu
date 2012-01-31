class AddIndexes < ActiveRecord::Migration
  def self.up
    add_index :items, :external_uid
    add_index :items, :path
    add_index :items, :positive_score
    add_index :items, :negative_score
    add_index :items, :controversiality
    add_index :acks, :item_id
    add_index :acks, :identity
    add_index :acks, :score
  end

  def self.down
  end
end

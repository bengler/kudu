class RenameItemsToScores < ActiveRecord::Migration
  def self.up
    rename_table :items, :scores
    rename_column :acks, :item_id, :score_id
    rename_column :acks, :score, :value
  end

  def self.down
    rename_table :scores, :items
    rename_column :acks, :score_id, :item_id
    rename_column :acks, :value, :score
  end
end

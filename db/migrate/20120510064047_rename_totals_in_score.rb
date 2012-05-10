class RenameTotalsInScore < ActiveRecord::Migration
  def self.up
    rename_column :scores, :positive_score, :positive
    rename_column :scores, :negative_score, :negative
  end

  def self.down
    rename_column :scores, :positive, :positive_score
    rename_column :scores, :negative, :negative_score
  end
end

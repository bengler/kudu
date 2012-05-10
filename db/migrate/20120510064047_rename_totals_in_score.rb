class RenameTotalsInScore < ActiveRecord::Migration
  def self.up
    rename_column :scores, :positive_score, :total_positive
    rename_column :scores, :negative_score, :total_negative
  end

  def self.down
    rename_column :scores, :total_positive, :positive_score
    rename_column :scores, :total_negative, :negative_score
  end
end

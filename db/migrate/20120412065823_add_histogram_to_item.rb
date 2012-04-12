class AddHistogramToItem < ActiveRecord::Migration
  def self.up
    add_column :items, :histogram, :text
  end

  def self.down
    remove_column :items, :histogram
  end
end

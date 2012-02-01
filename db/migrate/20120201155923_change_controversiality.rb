class ChangeControversiality < ActiveRecord::Migration
  def self.up
    change_column :items, :controversiality, :integer, :default => 0
  end

  def self.down
    change_column :items, :controversiality, :float, :default => nil
  end
end

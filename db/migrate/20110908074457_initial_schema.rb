class InitialSchema < ActiveRecord::Migration
  
  def self.up
    create_table :acks do |t|
      t.text :post_uid, :null => false
      t.text :identity, :null => false
      t.text :collection
      t.integer :score
      t.timestamps
    end
  end

  def self.down
    drop_table :acks
  end

end

class InitialSchema < ActiveRecord::Migration
  
  def self.up
    create_table :kudos do |t|
      t.text :post_uid, :null => false
      t.text :identity, :null => false
      t.text :collection
      t.integer :score
      t.timestamps
    end
  end

  def self.down
    drop_table :kudos
  end

end

class InitialSchema < ActiveRecord::Migration
  
  def self.up

    create_table :acks do |t|
      t.text :external_uid, :null => false
      t.integer :identity, :null => false
      t.integer :score
      t.timestamps
    end

  end

  def self.down
    drop_table :acks
  end

end

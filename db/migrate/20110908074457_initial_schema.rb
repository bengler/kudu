class InitialSchema < ActiveRecord::Migration
  
  def self.up

    create_table :summaries do |t|
      t.text :external_uid, :null => false
      t.text :collection
      t.integer :count
      t.integer :positive
      t.integer :negative
      t.integer :contro
      t.timestamps
    end

    create_table :acks do |t|
      t.integer :summary_id, :null => false
      t.integer :identity, :null => false
      t.integer :score
      t.timestamps
    end

    execute "alter table acks add foreign key (summary_id) references summaries (id)"

  end

  def self.down
    drop_table :acks
  end

end

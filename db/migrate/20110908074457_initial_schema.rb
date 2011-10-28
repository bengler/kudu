class InitialSchema < ActiveRecord::Migration
  
  def self.up

    create_table :summaries do |t|
      t.text :external_uid, :null => false
      t.text :collection
      t.integer :count,     :default => 0
      t.integer :positive,  :default => 0
      t.integer :negative,  :default => 0
      t.integer :contro,    :default => 0
      t.timestamps
    end

    create_table :acks do |t|
      t.text :external_uid, :null => false
      t.integer :summary_id, :null => false
      t.integer :identity, :null => false
      t.integer :score
      t.timestamps
    end

    execute "alter table acks add foreign key (summary_id) references summaries (id)"

  end

  def self.down
    execute "alter table acks remove foreign key (summary_id)"
    drop_table :acks
    drop_table :summaries
  end

end

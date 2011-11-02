class InitialSchema < ActiveRecord::Migration
  
  def self.up

    create_table :summaries do |t|
      t.text :external_uid, :null => false
      t.integer :total_ack_count,     :default => 0
      t.integer :positive_ack_count,  :default => 0
      t.integer :negative_ack_count,  :default => 0
      t.integer :neutral_ack_count,   :default => 0
      t.integer :positive_score,      :default => 0
      t.integer :negative_score,      :default => 0
      t.integer :controversiality
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
    execute "alter table acks drop constraint acks_summary_id_fkey"
    drop_table :acks
    drop_table :summaries
  end

end

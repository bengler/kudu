class InitialSchema < ActiveRecord::Migration

  def self.up

    create_table :items do |t|
      t.text    :external_uid,      :null => false
      t.text    :path
      t.integer :total_count,       :default => 0
      t.integer :positive_count,    :default => 0
      t.integer :negative_count,    :default => 0
      t.integer :neutral_count,     :default => 0
      t.integer :positive_score,    :default => 0
      t.integer :negative_score,    :default => 0
      t.float   :controversiality
      t.timestamps
    end

    create_table :acks do |t|
      t.integer :item_id
      t.integer :identity, :null => false
      t.integer :score
      t.timestamps
    end

    execute "alter table acks add foreign key (item_id) references items (id)"

  end

  def self.down
    execute "alter table acks drop constraint acks_item_id_fkey"
    drop_table :acks
    drop_table :items
  end

end

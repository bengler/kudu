class AddKindToScores < ActiveRecord::Migration
  def self.up
    add_column :scores, :kind, :string
    execute("update scores set kind='votes'") # Set to votes for dittforslag
    
    # We have quite a few duplicate score objects in the db.
    # I'm cleaning up those and adding an unique index on (external_uid, kind)
    duplicates = {}
    find_dups_sql = "select s1.external_uid, s1.id id1, s2.id id2 from scores s1, scores s2 where s1.external_uid = s2.external_uid and s1.id <> s2.id"
    execute(find_dups_sql).each do |row|
      next if duplicates.has_key?(row['id2'])
      duplicates[row['id1']] ||= []
      duplicates[row['id1']] << row['id2']
    end

    duplicates.each_pair do |master, dups|
      # move acks from the duplicates to "master" score
      execute("update acks set score_id='#{master}' where score_id IN (#{dups.join(",")})")

      # delete the duplicated scores
      execute("delete from scores where id IN (#{dups.join(",")})")
    end

    Score.calculate_all # recalculate all scores

    change_column :scores, :kind, :text, :null => false
    add_index :scores, :kind
    add_index :scores, [:external_uid, :kind], :unique => true
  end

  def self.down
    remove_column :scores, :kind
  end
end
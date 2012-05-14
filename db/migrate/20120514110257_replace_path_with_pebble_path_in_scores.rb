class ReplacePathWithPebblePathInScores < ActiveRecord::Migration
  def self.up
    labels = [:label_0, :label_1, :label_2, :label_3, :label_4, :label_5, :label_6, :label_7, :label_8, :label_9]
    labels.each do |label|
      send :add_column, :scores, label, :text
    end

    add_index :scores, labels, :name => 'index_scores_on_labels'

    say "Migrating existing paths to pebble_path"

    counter = 0
    execute("SELECT id, path FROM scores").each do |score|
      counter += 1
      say " ... working" if (counter % 100) == 0

      id = score["id"]
      values = score["path"].split('.')

      new_values = []
      (0...values.size).each do |i|
        new_values << "label_#{i}='#{values[i]}'"
      end
      sql = "UPDATE scores SET #{new_values.join(', ')} WHERE id=#{id}"
      execute(sql)
    end

    remove_column :scores, :path
  end

  def self.down
    add_column :scores, :path, :text
    add_index :scores, :path

    labels = [:label_0, :label_1, :label_2, :label_3, :label_4, :label_5, :label_6, :label_7, :label_8, :label_9]

    counter = 0
    execute("SELECT id, #{labels.join(', ')} FROM scores").each do |score|
      counter += 1
      say " ... working" if (counter % 100) == 0

      id = score["id"]
      values = labels.map {|label| score[label.to_s]}
      path = values.compact.join('.')

      sql = "UPDATE scores SET path='#{path}' WHERE id=#{id}"
      execute(sql)
    end

    labels.each do |label|
      send :remove_column, :scores, label
    end

  end
end

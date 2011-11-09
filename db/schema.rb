# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110908074457) do

  create_table "acks", :force => true do |t|
    t.text     "external_uid", :null => false
    t.integer  "summary_id"
    t.integer  "identity",     :null => false
    t.integer  "score"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "summaries", :force => true do |t|
    t.text     "external_uid",                      :null => false
    t.integer  "total_ack_count",    :default => 0
    t.integer  "positive_ack_count", :default => 0
    t.integer  "negative_ack_count", :default => 0
    t.integer  "neutral_ack_count",  :default => 0
    t.integer  "positive_score",     :default => 0
    t.integer  "negative_score",     :default => 0
    t.float    "controversiality"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end

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

  create_table "archives", :force => true do |t|
    t.text     "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "photos", :force => true do |t|
    t.text     "archive"
    t.text     "uid"
    t.float    "lon"
    t.float    "lat"
    t.text     "people"
    t.text     "location"
    t.integer  "year"
    t.integer  "month"
    t.integer  "day"
    t.text     "title"
    t.text     "description"
    t.text     "raw_metadata"
    t.text     "time_of_day"
    t.text     "time_of_year"
    t.integer  "confidence_level"
    t.float    "aspect_ratio"
    t.text     "sizes"
    t.datetime "taken_at"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end

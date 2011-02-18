# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110218135146) do

  create_table "igcfiles", :force => true do |t|
    t.string   "filename"
    t.float    "wind_direction"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "path"
    t.integer  "proc_version"
    t.float    "wind_speed"
  end

  add_index "igcfiles", ["filename"], :name => "index_igcfiles_on_filename", :unique => true

  create_table "igcpoints", :force => true do |t|
    t.integer  "enl"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "igcfile_id"
    t.integer  "seq_secs"
    t.integer  "gps_alt"
    t.integer  "baro_alt"
    t.string   "lat_lon",    :limit => 20
    t.integer  "x"
    t.integer  "y"
    t.float    "rlat"
    t.float    "rlon"
  end

  add_index "igcpoints", ["igcfile_id", "seq_secs"], :name => "index_igcpoints_on_igcfile_id_and_seq_secs", :unique => true

  create_table "windpoints", :force => true do |t|
    t.integer "igcfile_id"
    t.float   "direction"
    t.float   "speed"
    t.integer "altitude"
    t.integer "seq_secs"
    t.float   "dlon"
    t.float   "dlat"
    t.float   "dlon2"
    t.float   "dlat2"
    t.integer "altitude2"
    t.integer "seq_secs2"
    t.float   "climb"
  end

  add_index "windpoints", ["igcfile_id"], :name => "index_windpoints_on_igcfile_id"

end

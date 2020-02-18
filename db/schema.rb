ActiveRecord::Schema.define(:version => 20130219005243) do

  create_table "accounts", :force => true do |t|
    t.string   "username"
    t.string   "account_name"
    t.integer  "currency"
    t.integer  "glory"
    t.datetime "last_recruited"
    t.datetime "last_login"
    t.datetime "last_daily"
    t.string   "hash_key"
    t.string   "password"
    t.string   "salt"
    t.string   "email"
    t.boolean  "verified"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "armours", :force => true do |t|
    t.string   "name"
    t.string   "a_type"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "bout_histories", :force => true do |t|
    t.integer  "winner_id"
    t.integer  "loser_id"
    t.integer  "acc_1_id"
    t.integer  "acc_2_id"
    t.string   "hash_key"
    t.text     "json_text"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "char_mods", :force => true do |t|
    t.integer  "character_id"
    t.string   "m_key"
    t.string   "m_type"
    t.datetime "expires"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "characters", :force => true do |t|
    t.string   "name"
    t.integer  "level"
    t.integer  "exp"
    t.integer  "base_str"
    t.integer  "base_agi"
    t.integer  "base_end"
    t.integer  "base_int"
    t.integer  "base_x"
    t.integer  "att_points"
    t.integer  "wins"
    t.integer  "losses"
    t.boolean  "alive"
    t.string   "activity"
    t.integer  "activity_val"
    t.integer  "kills"
    t.datetime "last_daily"
    t.datetime "recovery_time"
    t.integer  "weapon_id"
    t.integer  "armour_id"
    t.integer  "tourney_id"
    t.integer  "account_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "notifications", :force => true do |t|
    t.string   "subject"
    t.text     "text"
    t.boolean  "read"
    t.integer  "account_id"
    t.integer  "character_id"
    t.string   "noti_type"
    t.string   "link_hash"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "recruits", :force => true do |t|
    t.string   "name"
    t.integer  "str"
    t.integer  "agi"
    t.integer  "end"
    t.integer  "int"
    t.integer  "x"
    t.integer  "price"
    t.string   "trait"
    t.integer  "account_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "weapons", :force => true do |t|
    t.string   "name"
    t.integer  "min_dmg"
    t.integer  "max_dmg"
    t.integer  "crit"
    t.string   "w_type"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end

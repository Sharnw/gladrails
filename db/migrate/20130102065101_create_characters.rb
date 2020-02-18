class CreateCharacters < ActiveRecord::Migration
  def change
    create_table :characters do |t|
      t.string   :name
      t.integer  :level
      t.integer  :exp
      t.integer  :base_str
      t.integer  :base_agi
      t.integer  :base_end
      t.integer  :base_int
      t.integer  :base_x
      t.integer  :att_points
      t.integer  :wins
      t.integer  :losses
      t.boolean  :alive
      t.string   :activity
      t.integer  :activity_val
      t.integer  :kills
      t.datetime :last_daily
      t.datetime :recovery_time
      t.integer  :weapon_id
      t.integer  :armour_id
      t.integer  :tourney_id
      t.integer  :account_id

      t.timestamps
    end
  end
end

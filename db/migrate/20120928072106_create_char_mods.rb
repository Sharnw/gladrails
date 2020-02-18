class CreateCharMods < ActiveRecord::Migration
  def change
    create_table :char_mods do |t|
      t.integer :character_id
      t.string :m_key
      t.string :m_type
      t.datetime :expires

      t.timestamps
    end
  end
end

class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.string  :subject
      t.text    :text
      t.boolean :read
      t.integer :account_id
      t.integer :character_id
      t.string  :noti_type
      t.string  :link_hash

      t.timestamps
    end
  end
end

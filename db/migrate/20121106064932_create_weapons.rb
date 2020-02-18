class CreateWeapons < ActiveRecord::Migration
  def change
    create_table :weapons do |t|
      t.string :name
      t.integer :min_dmg
      t.integer :max_dmg
      t.integer :crit
      t.string :w_type

      t.timestamps
    end
  end
end

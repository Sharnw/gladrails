class CreateRecruits < ActiveRecord::Migration
  def change
    create_table :recruits do |t|
      t.string :name
      t.integer :str
      t.integer :agi
      t.integer :end
      t.integer :int
      t.integer :x
      t.integer :price
      t.string :trait
      t.integer :account_id

      t.timestamps
    end
  end
end

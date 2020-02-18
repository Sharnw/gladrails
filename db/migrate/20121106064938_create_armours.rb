class CreateArmours < ActiveRecord::Migration
  def change
    create_table :armours do |t|
      t.string :name
      t.string :a_type

      t.timestamps
    end
  end
end

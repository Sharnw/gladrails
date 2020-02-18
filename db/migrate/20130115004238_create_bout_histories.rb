class CreateBoutHistories < ActiveRecord::Migration
  def change
    create_table :bout_histories do |t|
      t.integer :winner_id
      t.integer :loser_id
      t.integer :acc_1_id
      t.integer :acc_2_id
      t.string  :hash_key
      t.text    :json_text
      t.timestamps
    end
  end
end

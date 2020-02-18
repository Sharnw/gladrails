class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :username
      t.string :account_name
      t.integer :currency
      t.integer :glory
      t.datetime :last_recruited
      t.datetime :last_login
      t.datetime :last_daily
      t.string :hash_key
      t.string :password
      t.string :salt
      t.string :email
      t.boolean :verified

      t.timestamps
    end
  end
end

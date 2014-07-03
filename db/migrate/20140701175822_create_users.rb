class CreateUsers < ActiveRecord::Migration
  using(*Sharting.shard_names)
  
  def change
    create_table :users, id: false do |t|
      t.integer :id, limit: 8, primary: true, null: false
      t.string :name
      t.string :email
      t.string :crypted_password, :limit => 128
      t.string  :phone, :limit => 20
      t.timestamps
    end
  end
end

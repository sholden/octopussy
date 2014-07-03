class CreateUsers < ActiveRecord::Migration
  using(*Sharting.shard_names)
  
  def change
    create_table :users do |t|
      t.string :name
      t.string :crypted_email
      t.string :crypted_password, :limit => 128
      t.string  :phone, :limit => 20
      t.timestamps
    end
  end
end

class AddIndexes < ActiveRecord::Migration
  using(*Sharting.shard_names)

  def change
    add_index :vehicles, :user_id
    add_index :options, :vehicle_id
    add_index :prices, :vehicle_id
  end
end

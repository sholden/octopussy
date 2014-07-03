class AddShardedIdToUsers < ActiveRecord::Migration
  using(*Sharting.shard_names)

  def change
    add_column :users, :sharded_id, :integer, :limit => 8
  end
end

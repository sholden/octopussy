class CreatePrices < ActiveRecord::Migration
  using(*Sharting.shard_names)

  def change
    create_table :prices do |t|
      t.integer :vehicle_id

      t.decimal :price, :precision => 8, :scale => 2
      t.timestamps
    end
  end
end

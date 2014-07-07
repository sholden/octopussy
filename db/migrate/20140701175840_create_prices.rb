class CreatePrices < ActiveRecord::Migration
  using(*Sharting.shard_names)

  def change
    create_table :prices, id: false do |t|
      t.integer :id, limit: 8, unsigned: true, primary: true, null: false
      t.integer :vehicle_id, limit: 8, unsigned: true, null: false

      t.decimal :price, :precision => 8, :scale => 2
      t.timestamps
    end
  end
end

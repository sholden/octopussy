class CreateVehicles < ActiveRecord::Migration
  using(*Sharting.shard_names)

  def change
    create_table :vehicles, id: false do |t|
      t.integer :id, limit: 8, primary: true, null: false
      t.integer :user_id, null: false
      
      t.integer :year
      t.string :make, :limit => 100
      t.string :model, :limit => 100
      t.string :trim, :limit => 100
      t.string :interior_color, :limit => 100
      t.string :exterior_color, :limit => 100

      t.decimal :sticker_price, :precision => 10, :scale => 2
      t.timestamps
    end
  end
end

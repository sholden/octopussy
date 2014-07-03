class CreateOptions < ActiveRecord::Migration
  using(*Sharting.shard_names)

  def change
    create_table :options do |t|
      t.integer :vehicle_id

      t.text    :description
      t.string  :opt_code, :limit => 20
      t.boolean :is_quick_package
      t.boolean :is_option_package
      t.boolean :is_dio_option
      t.decimal :msrp, :precision => 9, :scale => 2
      t.decimal :invoice, :precision => 9, :scale => 2

      t.string :opt_kind
      t.string :opt_code
      t.timestamps
    end
  end
end

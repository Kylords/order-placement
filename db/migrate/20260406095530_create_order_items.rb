class CreateOrderItems < ActiveRecord::Migration[5.2]
  def change
    create_table :order_items do |t|
      t.references :order, foreign_key: true, null: false
      t.references :product, foreign_key: true, null: false
      t.integer :quantity, null: false, default: 1
      t.decimal :price, precision: 10, scale: 2, null: false

      t.timestamps
    end
  end
end

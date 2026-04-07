class AddTotalAmountToCarts < ActiveRecord::Migration[5.2]
  def change
    add_column :carts, :total_amount, :decimal, precision: 10, scale: 2, default: 0.0, null: false
  end
end

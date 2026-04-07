class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
      t.references :user, foreign_key: true, null: false
      t.string :status, null: false, default: "pending"
      t.decimal :total_amount, precision: 10, scale: 2, default: 0.0

      t.timestamps
    end
  end
end

class CreateProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :products do |t|
      t.string :name
      t.string :code
      t.decimal :price
      t.string :status
    end
  end
end
class CreateProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.string :code, null: false, unique: true
      t.decimal :price, precision: 10, scale: 2, null: false
      t.string :status, null: false, default: "C"

      t.timestamps
    end
  end
end

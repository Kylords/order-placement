class Product < ApplicationRecord
  has_many :order_items
  has_many :orders, through: :order_items

  has_many :cart_items, dependent: :destroy
  has_many :carts, through: :cart_items

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :status, presence: true, inclusion: { in: ["C", "A"] }
end
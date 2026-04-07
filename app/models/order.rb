class Order < ApplicationRecord
  has_many :order_items
  has_many :products, through: :order_items
  belongs_to :user

  accepts_nested_attributes_for :order_items

  validates :status, presence: true, inclusion: { in: ["pending", "completed"] }
  validates :total_amount, numericality: { greater_than_or_equal_to: 0 }
end
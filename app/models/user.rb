class User < ApplicationRecord
  has_secure_password

  has_many :orders, dependent: :destroy
  has_one :cart, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :role, inclusion: { in: ["customer", "admin"] }
end
class Cart < ApplicationRecord
  belongs_to :user
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  def update_total_amount!
    total = cart_items.includes(:product).sum { |item| item.product.price * item.quantity }
    update!(total_amount: total)
  end

  def checkout
    return if cart_items.empty?

    order = user.orders.create!(status: 'pending')
    total = 0

    cart_items.each do |item|
      order.order_items.create!(
        product: item.product,
        quantity: item.quantity,
        price: item.product.price
      )
      total += item.product.price * item.quantity
    end

    order.update!(total_amount: total)

    cart_items.destroy_all
    update!(total_amount: 0)

    order
  end
end
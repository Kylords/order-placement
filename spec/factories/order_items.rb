FactoryBot.define do
  factory :order_item do
    product
    quantity { 1 }
    price { product.price }
    order
  end
end
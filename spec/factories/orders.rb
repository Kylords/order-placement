FactoryBot.define do
  factory :order do
    user
    total_amount { 0 }
    status { 'pending' }

    # nested order items
    after(:build) do |order|
      if order.order_items.empty?
        order.order_items << build(:order_item, order: order)
      end
    end
  end
end
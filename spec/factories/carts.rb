FactoryBot.define do
  factory :cart do
    association :user

    # optional: create cart_items when needed
    transient do
      items_count { 0 }
    end

    after(:create) do |cart, evaluator|
      if evaluator.items_count > 0
        create_list(:cart_item, evaluator.items_count, cart: cart)
      end
    end
  end
end
FactoryBot.define do
  factory :user do
    name { "Test User" }
    email { Faker::Internet.unique.email }
    password { "password123" }
    role { "customer" }

    trait :admin do
      role { "admin" }
    end
  end
end
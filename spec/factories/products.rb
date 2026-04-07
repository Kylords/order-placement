FactoryBot.define do
  factory :product do
    name { Faker::Coffee.variety }
    code { Faker::Alphanumeric.alphanumeric(number: 5).upcase }
    price { rand(50..500) }
    status { 'A' }
  end
end
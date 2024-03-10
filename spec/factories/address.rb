FactoryBot.define do
  factory :address do
    street { Faker::Address.street_address }
    city { Faker::Address.city }
    state { Faker::Address.state }
    zipcode { Faker::Address.zip_code }
    country { "USA" }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }
    additional_info { Faker::Lorem.sentence }
  end
end
FactoryBot.define do
  factory :homeowner_request do
    description { Faker::Lorem.paragraph }
    association :homeowner, factory: :homeowner

    # Add any other attributes as needed
  end

  factory :contractor_homeowner_request do
    association :contractor, factory: :contractor
    association :homeowner_request
    status { 0 } # or any default status value you prefer

    # Add any other attributes as needed
  end
end


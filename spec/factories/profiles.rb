FactoryBot.define do
  factory :profile do
    # Associations
    user
    # Other attributes
    hourly_rate { Faker::Number.decimal(l_digits: 2) }
    years_of_experience { Faker::Number.between(from: 0, to: 50) }
    availability { false }
    have_insurance { Faker::Boolean.boolean }
    have_license { Faker::Boolean.boolean }
    name { Faker::Name.name }
    phone_number { Faker::PhoneNumber.phone_number }
    image_data { Faker::LoremFlickr.image(size: "50x50", search_terms: ['profile']) }
    website { Faker::Internet.url }
    license_number { Faker::Lorem.word }
    insurance_provider { Faker::Lorem.word }
    insurance_policy_number { Faker::Lorem.word }
    service_area { Faker::Address.community }
    specializations { Faker::Lorem.words(number: 3) }
    certifications { Faker::Lorem.words(number: 3) }
    languages_spoken { Faker::Lorem.words(number: 3) }
    description { Faker::Lorem.paragraph }

    # Address attributes
    after(:build) do |profile|
      profile.addresses << FactoryBot.build(:address, addressable: profile)
    end
  end
end



# spec/factories/profiles.rb
#
# FactoryBot.define do
#   factory :profile do
#     user
#     first_name { "John" }
#     last_name { "Doe" }
#     bio { "Lorem ipsum dolor sit amet, consectetur adipiscing elit." }
#     # Add other profile attributes as needed
#   end
# end
# ruby
# Copy code
# # spec/factories/advertisements.rb
#
# FactoryBot.define do
#   factory :advertisement do
#     title { "Ad Title" }
#     url { "https://example.com" }
#     link { "https://example.com" }
#     service
#     # Add other advertisement attributes as needed
#   end
# end


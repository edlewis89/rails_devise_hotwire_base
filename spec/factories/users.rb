# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { 'password' }
    password_confirmation { 'password' }
    verified { true }
    role { :general }
    active { true }
    public { true }
    type { 'General' }
  end
end


#
# FactoryBot.define do
#   factory :user do
#     #name { Faker::Name.name }
#     email { Faker::Internet.email }
#     password { 'password1234' } # Replace with your desired password
#     #birthdate { Faker::Date.birthday(min_age: 18, max_age: 65) }
#     role { 'general' }
#
#     #jti { SecureRandom.uuid }
#     #type { 'User' }
#
#     # trait :member do
#     #   type { 'Member' }
#     #   role { 'member' }
#     # end
#     #
#     # trait :with_profile do
#     #   after(:create) { |user| create(:profile, user: user) }
#     # end
#     #
#     # trait :with_subscription do
#     #   after(:create) { |user| user.subscribe }
#     # end
#   end
# end

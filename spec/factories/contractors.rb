# spec/factories/contractors.rb
FactoryBot.define do
  factory :contractor, parent: :user, class: 'Contractor' do
    email { Faker::Internet.email }
    password { 'password' }
    password_confirmation { 'password' }
    verified { true }
    active { true }
    role { :contractor }
    type { 'Contractor' }

    trait :with_unavailable_inactive_profile do
      after(:create) do |homeowner|
        create(:profile, profileable: homeowner)
      end
    end

    # Define a trait to customize the profile attributes
    trait :with_available_profile do
      after(:create) do |homeowner|
        create(:profile, profileable: homeowner, availability: true)
      end
    end
  end
end
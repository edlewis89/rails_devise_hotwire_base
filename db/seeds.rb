# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# admin = FactoryBot.create(:user, name: "Admin", role: :admin, email: "admin@gmail.com", password: "password", password_confirmation: "password")
# puts "admin user created #{admin.email}"
# puts "admin ? #{admin.admin?}"
#
# contractor = FactoryBot.create(:user, name: "Contractor", role: :contractor, email: "contractor@gmail.com", password: "password", password_confirmation: "password")
# puts "contractor user created #{contractor.email}"
# puts "contractor ? #{contractor.contractor?}"
#
# homeowner = FactoryBot.create(:user, name: "Homeowner", role: :homeowner, email: "homeowner@gmail.com", password: "password", password_confirmation: "password")
# puts "homeowner user created #{homeowner.email}"
# puts "homeowner ? #{homeowner.homeowner?}"

#admin = FactoryBot.create(:user, role: :admin, email: "admin@gmail.com", password: "password", password_confirmation: "password")
#contractor = FactoryBot.create(:user, role: :contractor, email: "contractor@gmail.com", password: "password", password_confirmation: "password")
#homeowner = FactoryBot.create(:user, role: :homeowner, email: "homeowner@gmail.com", password: "password", password_confirmation: "password")

# # Create Admin User
# admin = User.create(email: 'admin@example.com', password: "password", password_confirmation: "password", role: 'admin')
#
# # Create Contractor User
# contractor = FactoryBot.create(:contractor)
# # Ensure that the association between the contractor profile and the contractor is correctly assigned
# contractor_profile = FactoryBot.create(:profile, :contractor_profile, active: false, availability: true, profileable: contractor)
#
# # Create Homeowner User
#
# homeowner = FactoryBot.create(:homeowner)
# homeowner_profile = FactoryBot.create(:profile, :homeowner_profile, active: false, availability: true, profileable: homeowner)
#
# # Create Homeowner Request associated with the homeowner
# homeowner_request = FactoryBot.create(:homeowner_request, homeowner_id: homeowner.id)
#
# puts 'Seed data generated successfully.'

# Seed File
#
# # Create Admin User
# admin = User.create(email: 'admin@example.com', password: 'password', verified: true)
#
# # Create Homeowner Profile
# homeowner = FactoryBot.create(:homeowner, :with_unavailable_profile)
#
# # Create Homeowner Profile
# homeowner = FactoryBot.create(:homeowner, :with_available_profile)
#
# # Create Contractor Profile
# contractor = FactoryBot.create(:contractor, :with_unavailable_profile)
#
# # Create Contractor Profile
# contractor = FactoryBot.create(:contractor, :with_available_profile)
#
# # Create Homeowner Request
# homeowner_request = FactoryBot.create(:homeowner_request, homeowner: homeowner)
# homeowner_request.save
#
# # Create Contractor Homeowner Request
# contractor_homeowner_request = FactoryBot.create(:contractor_homeowner_request, contractor: contractor, homeowner_request: homeowner_request)
# contractor_homeowner_request.save


admin = User.create!(
  email: 'admin@admin.com',
  password: 'password',
  verified: true,
  role: :admin, # or :contractor, depending on the type
  active: true,
  public: true
)


user = User.create!(
  email: 'general@example.com',
  password: 'password',
  verified: true,
  role: :general, # or :contractor, depending on the type
  active: true,
  public: true
)


homeowner = Homeowner.create!(
  email: 'homeowner@example.com',
  password: 'password',
  verified: true,
  role: :homeowner,
  active: true,
  public: true
)

contractor = Contractor.create!(
  email: 'contractor@example.com',
  password: 'password',
  verified: true,
  role: :contractor,
  active: true,
  public: true

)

homeowner_profile = Profile.create!(
  user: homeowner,
  profileable: homeowner,
  hourly_rate: Faker::Number.decimal(l_digits: 2),
  years_of_experience: Faker::Number.between(from: 0, to: 50),
  availability: true,
  have_insurance: Faker::Boolean.boolean,
  have_license: Faker::Boolean.boolean,
  name: Faker::Name.name,
  phone_number: Faker::PhoneNumber.phone_number,
  city: Faker::Address.city,
  state: Faker::Address.state,
  zipcode: Faker::Address.zip_code,
  image: Faker::LoremFlickr.image(size: "50x50", search_terms: ['profile']),
  website: Faker::Internet.url,
  license_number: Faker::Lorem.word,
  insurance_provider: Faker::Lorem.word,
  insurance_policy_number: Faker::Lorem.word,
  service_area: Faker::Address.community,
  specializations: Faker::Lorem.words(number: 3),
  certifications: Faker::Lorem.words(number: 3),
  languages_spoken: Faker::Lorem.words(number: 3),
  description: Faker::Lorem.paragraph
)

contractor_profile = Profile.create!(
  user: contractor,
  profileable: contractor,
  hourly_rate: Faker::Number.decimal(l_digits: 2),
  years_of_experience: Faker::Number.between(from: 0, to: 50),
  availability: true,
  have_insurance: Faker::Boolean.boolean,
  have_license: Faker::Boolean.boolean,
  name: Faker::Name.name,
  phone_number: Faker::PhoneNumber.phone_number,
  city: Faker::Address.city,
  state: Faker::Address.state,
  zipcode: Faker::Address.zip_code,
  image: Faker::LoremFlickr.image(size: "50x50", search_terms: ['profile']),
  website: Faker::Internet.url,
  license_number: Faker::Lorem.word,
  insurance_provider: Faker::Lorem.word,
  insurance_policy_number: Faker::Lorem.word,
  service_area: Faker::Address.community,
  specializations: Faker::Lorem.words(number: 3),
  certifications: Faker::Lorem.words(number: 3),
  languages_spoken: Faker::Lorem.words(number: 3),
  description: Faker::Lorem.paragraph
)


puts 'Seed data generated successfully.'


# Seed data for TypeOfWork
TypeOfWork.create([
                    { name: 'Plumbing' },
                    { name: 'Electrical' },
                    { name: 'Carpentry' },
                  # Add more types of work as needed
                  ])

puts 'Seed data for TypeOfWork created successfully'
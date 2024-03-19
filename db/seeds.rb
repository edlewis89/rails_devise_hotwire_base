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

admin = Admin.create!(
  email: 'lewiedw89@gmail.com',
  password: 'password',
  role: :admin,
  verified: true,
  active: true,
  public: true
)

gen = User.create!(
  email: 'general@example.com',
  password: 'password',
  role: :general,
  verified: true,
  active: true,
  public: true
)

homeowner = Homeowner.create!(
  email: 'basic@example.com',
  password: 'password',
  role: :property_owner,
  verified: true,
  active: true,
  public: true,
  subscription_level: :basic
)

contractor = Contractor.create!(
  email: 'starter@example.com',
  password: 'password',
  role: :service_provider,
  verified: true,
  active: true,
  public: true,
  subscription_level: :basic
)

homeowner = Homeowner.create!(
  email: 'prem_homeowner@example.com',
  password: 'password',
  role: :property_owner,
  verified: true,
  active: true,
  public: true,
  subscription_level: :premium
)

contractor = Contractor.create!(
  email: 'prem_contractor@example.com',
  password: 'password',
  role: :service_provider,
  verified: true,
  active: true,
  public: true,
  subscription_level: :premium
)

contractor = Contractor.create!(
  email: 'pro@example.com',
  password: 'password',
  role: :service_provider,
  verified: true,
  active: true,
  public: true,
  subscription_level: :pro
)

ad_manager = AdManager.create!(
  email: 'admanager@example.com',
  password: 'password',
  role: :ad_manager,
  verified: true,
  active: true,
  public: true
)

#homeowner_profile = FactoryBot.create(:profile, profileable_type: homeowner)
#contractor_profile = FactoryBot.create(:profile, profileable_type: contractor)

#puts 'Seed data generated successfully.'

hprofile = Profile.new(
  user: homeowner,
  #profileable_type: 'Homeowner',
  #profileable_id: homeowner.id,
  hourly_rate: Faker::Number.decimal(l_digits: 2),
  years_of_experience: Faker::Number.between(from: 0, to: 50),
  availability: true,
  have_insurance: Faker::Boolean.boolean,
  have_license: Faker::Boolean.boolean,
  name: Faker::Name.name,
  phone_number: Faker::PhoneNumber.phone_number,
  image_data: Faker::LoremFlickr.image(size: "50x50", search_terms: ['profile']),
  website: Faker::Internet.url,
  license_number: Faker::Lorem.word,
  insurance_provider: Faker::Lorem.word,
  insurance_policy_number: Faker::Lorem.word,
  service_area: Faker::Address.community,
  specializations: Faker::Lorem.words(number: 3),
  certifications: Faker::Lorem.words(number: 3),
  languages_spoken: Faker::Lorem.words(number: 3),
  description: Faker::Lorem.paragraph,
  addresses_attributes: [
    {
      street: Faker::Address.street_address,
      city: Faker::Address.city,
      state: Faker::Address.state_abbr,
      zipcode: Faker::Address.zip_code,
      country: "USA",
      latitude: Faker::Address.latitude,
      longitude: Faker::Address.longitude,
      additional_info: Faker::Lorem.sentence
    }
  ]
)

if hprofile.save
  puts "Homeowner created and indexed"
else
  puts "Error creating homeowner: #{hprofile.errors.full_messages.join(', ')}"
end

cprofile = Profile.create!(
  user: contractor,
  #profileable_type: 'Contractor',
  #profileable_id: contractor.id,
  hourly_rate: Faker::Number.decimal(l_digits: 2),
  years_of_experience: Faker::Number.between(from: 0, to: 50),
  availability: true,
  have_insurance: Faker::Boolean.boolean,
  have_license: Faker::Boolean.boolean,
  name: Faker::Name.name,
  phone_number: Faker::PhoneNumber.phone_number,
  image_data: Faker::LoremFlickr.image(size: "50x50", search_terms: ['profile']),
  website: Faker::Internet.url,
  license_number: Faker::Lorem.word,
  insurance_provider: Faker::Lorem.word,
  insurance_policy_number: Faker::Lorem.word,
  service_area: Faker::Address.community,
  specializations: Faker::Lorem.words(number: 3),
  certifications: Faker::Lorem.words(number: 3),
  languages_spoken: Faker::Lorem.words(number: 3),
  description: Faker::Lorem.paragraph,
  addresses_attributes: [
    {
      street: Faker::Address.street_address,
      city: Faker::Address.city,
      state: Faker::Address.state_abbr,
      zipcode: Faker::Address.zip_code,
      country: "USA",
      latitude: Faker::Address.latitude,
      longitude: Faker::Address.longitude,
      additional_info: Faker::Lorem.sentence
    }
  ]
)

if cprofile.save
  puts "Contractor profile created and indexed"
else
  puts "Error creating contractor: #{cprofile.errors.full_messages.join(', ')}"
end

ad_manager_profile = Profile.new(
  user: ad_manager,
  #profileable_type: 'AdManager',
  #profileable_id: ad_manager.id,
  hourly_rate: Faker::Number.decimal(l_digits: 2),
  years_of_experience: Faker::Number.between(from: 0, to: 50),
  availability: true,
  have_insurance: Faker::Boolean.boolean,
  have_license: Faker::Boolean.boolean,
  name: Faker::Name.name,
  phone_number: Faker::PhoneNumber.phone_number,
  image_data: Faker::LoremFlickr.image(size: "50x50", search_terms: ['profile']),
  website: Faker::Internet.url,
  license_number: Faker::Lorem.word,
  insurance_provider: Faker::Lorem.word,
  insurance_policy_number: Faker::Lorem.word,
  service_area: Faker::Address.community,
  specializations: Faker::Lorem.words(number: 3),
  certifications: Faker::Lorem.words(number: 3),
  languages_spoken: Faker::Lorem.words(number: 3),
  description: Faker::Lorem.paragraph,
  addresses_attributes: [
    {
      street: Faker::Address.street_address,
      city: Faker::Address.city,
      state: Faker::Address.state_abbr,
      zipcode: '20152',
      country: "USA",
      latitude: Faker::Address.latitude,
      longitude: Faker::Address.longitude,
      additional_info: Faker::Lorem.sentence
    }
  ]
)

if ad_manager_profile.save
  puts "Ad Manager profile created and indexed"
else
  puts "Error creating ad_manager_profile: #{ad_manager_profile.errors.full_messages.join(', ')}"
end

puts 'Seed data generated successfully.'


# Seed data for TypeOfWork
Service.create(name: 'Plumbing', description: 'Installation, repair, and maintenance of plumbing systems, including pipes, fixtures, and fittings.')
Service.create(name: 'Electrical', description: 'Installation, repair, and maintenance of electrical systems, including wiring, circuits, and fixtures.')
Service.create(name: 'Carpentry', description: 'Construction, repair, and installation of wooden structures, furniture, and fixtures.')
Service.create(name: 'Painting', description: 'Application of paint or other protective coatings to surfaces, such as walls, ceilings, and furniture.')
Service.create(name: 'Landscaping', description: 'Design, installation, and maintenance of outdoor landscapes, including gardens, lawns, and hardscapes.')
Service.create(name: 'HVAC (Heating, Ventilation, and Air Conditioning)', description: 'Installation, repair, and maintenance of heating, ventilation, and air conditioning systems.')
Service.create(name: 'Roofing', description: 'Installation, repair, and replacement of roofs and roofing materials, such as shingles, tiles, and metal.')
Service.create(name: 'Flooring', description: 'Installation and repair of various types of flooring, including hardwood, laminate, tile, and carpet.')
Service.create(name: 'Drywall', description: 'Installation and repair of drywall, also known as gypsum board or plasterboard, for interior walls and ceilings.')
Service.create(name: 'Window Installation', description: 'Installation and replacement of windows, including frame construction and sealing.')
Service.create(name: 'Door Installation', description: 'Installation and replacement of doors, including interior and exterior doors, frames, and hardware.')
Service.create(name: 'Pest Control', description: 'Management and removal of pests, including insects, rodents, and other unwanted creatures.')
Service.create(name: 'Appliance Repair', description: 'Repair and maintenance of household appliances, such as refrigerators, washers, dryers, and ovens.')
Service.create(name: 'Home Security', description: 'Installation and maintenance of security systems, including alarms, cameras, and monitoring services.')
Service.create(name: 'Home Cleaning', description: 'Professional cleaning services for residential properties, including general cleaning, deep cleaning, and specialized services.')
# Add more services as needed



# Create an Addressable entity (assuming Addressable is another model)
# address = Address.create(street: "123 Example St", city: "Example City", state: "Example State", zipcode: "20152")

# Create an Ad associated with the Service and Addressable entity
# ad = Advertisement.new(title: "Example Ad", image: "example_image.png", url: "example.com", service: Service.first, addresses_attributes: [
#   {
#     street: Faker::Address.street_address,
#     city: Faker::Address.city,
#     state: Faker::Address.state_abbr,
#     zipcode: '20152',
#     country: "USA",
#     latitude: Faker::Address.latitude,
#     longitude: Faker::Address.longitude,
#     additional_info: Faker::Lorem.sentence
#   }])
#
# if ad.save
#   puts "Ad created and indexed"
# else
#   puts "Error creating ad: #{ad.errors.full_messages.join(', ')}"
# end

puts "Seed Ad data created successfully!"
puts 'Seed data for Services created successfully'


  # # db/seeds.rb
  #
  # # Create a Profile
  # Profile.create!(
  #   user_id: 1,
  #   first_name: "John",
  #   last_name: "Doe",
  #   bio: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
  # # Add other profile attributes as needed
  #   )
  #
  # # Create an Advertisement
  # Advertisement.create!(
  #   title: "Ad Title",
  #   url: "https://example.com",
  #   link: "https://example.com",
  #   service_id: 1,
  # # Add other advertisement attributes as needed
  #   )
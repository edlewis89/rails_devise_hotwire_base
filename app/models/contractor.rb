class Contractor < User
  has_many :contractor_homeowner_requests
  has_many :homeowner_requests, through: :contractor_homeowner_requests

  has_many :service_requests, as: :user

  has_one :profile, as: :profileable, dependent: :destroy, touch: true # Ensure the associated profile is destroyed when the homeowner is destroyed

  #has_many :userable, polymorphic: true
  #has_many :users, as: :userable
  #after_create :create_profile

  private

  # def create_profile
  #   puts "Creating Contractor #{self.class.name} Profile >>>>>>>>>>>>>>>"
  #   # Ensure profile is initialized
  #   build_profile unless profile
  #   # Update profileable_type to indicate the user is a Homeowner
  #   profile.update(profileable_type: self.class.name.to_s)
  #   puts "Checking Profile Type #{profile.profileable_type} >>>>>>>>>>>>>>>"
  # end
end

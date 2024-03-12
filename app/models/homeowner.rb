class Homeowner < User
  has_many :homeowner_requests, dependent: :destroy
  has_many :service_requests

  has_one :profile, as: :profileable, dependent: :destroy
  #has_one :profile, class_name: 'Profile', as: :profileable

  delegate :name, :phone_number, :city, :state, :zipcode, to: :profile
  
  #has_one :profile, as: :profileable, dependent: :destroy, touch: true # Ensure the associated profile is destroyed when the homeowner is destroyed

  Rails.logger.info "#{name}: #{all.to_sql}"

  def profile
    profile = Profile.homeowner_profiles.find_by(profileable_id: self.id)
    profile ||= Profile.new(profileable_id: self.id, profileable_type: self.class.to_s)
    profile
  end

  def is_active?
    active # Assuming there's an 'active' attribute in the 'homeowners' table
  end

  private
  #
  # def create_profile
  #   puts "Creating Homeowner #{self.class.name} Profile >>>>>>>>>>>>>>>"
  #   # Create a new profile associated with the homeowner
  #   build_profile unless profile
  #   profile.update(profileable_type: self.class.name.to_s)
  #   puts "Checking Profile Type #{profile.profileable_type} >>>>>>>>>>>>>>>"
  # end
end

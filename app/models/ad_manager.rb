class AdManager < User
  has_one :profile, class_name: 'Profile', as: :profileable, dependent: :destroy

  delegate :name, :phone_number, :availability, :city, :state, :zipcode, :service_area,
           :website, :years_of_experience, :hourly_rate, :license_number, :insurance_provider,
           :insurance_policy_number, :have_insured, to: :profile

  def profile
    profile = Profile.ad_manager_profiles.find_by(profileable_id: self.id)
    profile ||= Profile.new(profileable_id: self.id, profileable_type: self.class.to_s)
    profile
  end

  def is_active?
    active # Assuming there's an 'active' attribute in the 'homeowners' table
  end

  private
end

class AdManager < User
  #has_one :profile, class_name: 'Profile', as: :profileable, dependent: :destroy
  has_one :profile, dependent: :destroy
  accepts_nested_attributes_for :profile

  delegate :name, :phone_number, :availability, :city, :state, :zipcode, :service_area,
           :website, :years_of_experience, :hourly_rate, :license_number, :insurance_provider,
           :insurance_policy_number, :have_insured, to: :profile

  def profile
    profile ||= Profile.find_or_initialize_by(user_id: id, user_type: self.class.name)
  end

  def is_active?
    active # Assuming there's an 'active' attribute in the 'homeowners' table
  end

  private
end

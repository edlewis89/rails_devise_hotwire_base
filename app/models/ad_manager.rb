class AdManager < User
  has_one :profile, foreign_key: 'user_id', dependent: :destroy

  accepts_nested_attributes_for :profile

  delegate :name, :phone_number, :availability, :city, :state, :zipcode, :service_area,
           :website, :years_of_experience, :hourly_rate, :license_number, :insurance_provider,
           :insurance_policy_number, :have_insured, to: :profile

  def is_active?
    active # Assuming there's an 'active' attribute in the 'homeowners' table
  end

  def profile
    profile ||= Profile.find_or_initialize_by(user_id: id)
  end

  private
end

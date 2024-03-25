class Homeowner < User
  has_one :profile, foreign_key: 'user_id', dependent: :destroy

  has_many :homeowner_requests, dependent: :destroy
  has_many :service_requests, foreign_key: :homeowner_id, dependent: :destroy
  has_many :reviews

  accepts_nested_attributes_for :profile

  delegate :name, :phone_number, to: :profile, prefix: false, allow_nil: false
  delegate :availability, :service_area,
           :website, :years_of_experience, :hourly_rate, :license_number, :insurance_provider,
           :insurance_policy_number, :have_insured, :have_license, to: :profile, prefix: false, allow_nil: true

  Rails.logger.info "#{name}: #{all.to_sql}"

  # def profile
  #   profile ||= Profile.find_or_initialize_by(user_id: id, user_type: self.class.name)
  # end

  def is_active?
    active # Assuming there's an 'active' attribute in the 'homeowners' table
  end

  def profile
    profile ||= Profile.find_or_initialize_by(user_id: id)
  end

  def self.with_service_requests
    includes(:service_requests).where.not(service_requests: { id: nil })
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

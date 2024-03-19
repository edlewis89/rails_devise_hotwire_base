class Homeowner < User
  has_many :homeowner_requests, dependent: :destroy
  has_many :service_requests, foreign_key: :homeowner_id, dependent: :destroy

  delegate :name, :phone_number, to: :profile

  Rails.logger.info "#{name}: #{all.to_sql}"

  # def profile
  #   profile ||= Profile.find_or_initialize_by(user_id: id, user_type: self.class.name)
  # end

  def is_active?
    active # Assuming there's an 'active' attribute in the 'homeowners' table
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

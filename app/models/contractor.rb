class Contractor < User
  has_many :contractor_homeowner_requests
  has_many :homeowner_requests, through: :contractor_homeowner_requests
  
  has_many :service_responses

  has_one :profile, class_name: 'Profile', as: :profileable, dependent: :destroy

  #has_one :profile, as: :profileable, dependent: :destroy, touch: true # Ensure the associated profile is destroyed when the homeowner is destroyed

  delegate :name, :phone_number, :availability, :city, :state, :zipcode, :service_area,
           :website, :years_of_experience, :hourly_rate, :license_number, :insurance_provider,
           :insurance_policy_number, :have_insured, to: :profile


  # contractor = Contractor.find(contractor_id)
  # service_request = ServiceRequest.find(service_request_id)
  # responses = contractor.responses_for_request(service_request)
  def responses_for_request(service_request)
    service_responses.where(service_request_id: service_request.id)
  end

  def all_responses
    ServiceResponse.joins(:service_request).where(service_requests: { contractor_id: id })
  end

  def profile
    profile = Profile.contractor_profiles.find_by(profileable_id: self.id)
    profile ||= Profile.new(profileable_id: self.id, profileable_type: self.class.to_s)
    profile
  end

  def is_active?
    active # Assuming there's an 'active' attribute in the 'homeowners' table
  end

  def self.active_search(query)
    # Fetch active contractors with their associated profiles
    active_contractors = includes(:profile).where(active: true)

    contractor_results = []

    active_contractors.each do |contractor|
      # Use the associated profile to perform Elasticsearch search
      # Assuming the Profile model has the `search_in_elasticsearch` method
      #contractor_results << contractor.profile.search_in_elasticsearch(query)
      # puts ">>>> #{contractor.profile.elastic_repo_search(query).inspect}"

      contractor_results << contractor.profile.search_in_elasticsearch(query)
    end

    # puts ">>>> results #{contractor_results.inspect}"
    contractor_results
  end


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

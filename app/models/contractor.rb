class Contractor < User
  has_many :contractor_homeowner_requests
  has_many :homeowner_requests, through: :contractor_homeowner_requests

  has_many :service_responses, foreign_key: :contractor_id, dependent: :destroy
  has_many :bids, foreign_key: :contractor_id, dependent: :destroy

  has_many :contractor_services
  has_many :services, through: :contractor_services

  delegate :name, :phone_number, :availability, :service_area,
           :website, :years_of_experience, :hourly_rate, :license_number, :insurance_provider,
           :insurance_policy_number, :have_insured, :have_license, to: :profile, allow_nil: true

  delegate :type, to: :user, prefix: true, allow_nil: true

  
#  Define the Criteria: Determine the criteria for matching a contractor with a service request. This includes the service request's zipcode, the range within which the contractor should be located, and the required skills for the service.
#
#  Retrieve Contractors: Query the database to retrieve contractors that match the specified criteria. This query should consider the zipcode, range, and skills.
#
#  Match Contractors with Service Requests: Iterate over the retrieved contractors and match them with service requests based on their proximity to the service request's zipcode and their skills.
#
#  Return Matched Contractors: Return the matched contractors to be displayed or processed further.
   scope :within_range, ->(zipcode, range) {
    where(zipcode: zipcode).near(zipcode, range)
  }

  # contractor = Contractor.find(contractor_id)
  # service_request = ServiceRequest.find(service_request_id)
  # responses = contractor.responses_for_request(service_request)

  def self.match_with_service_request(service_request, zipcode:, active: true, public_only: true)
    # Get the IDs of services needed in the request
    required_service_ids = service_request.service_ids

    # Start with a base query for contractors who provide all the required services
    contractors = Contractor.joins(:services)
                            .where(services: { id: required_service_ids })
                            .group('contractors.id')
                            .having('COUNT(services.id) = ?', required_service_ids.count)

    # Filter based on active status if specified
    contractors = contractors.active if active

    # Filter based on privacy setting if specified
    contractors = contractors.where(public: true) if public_only

    # Filter based on zipcode
    contractors = contractors.within_range(zipcode, service_request.range)

    contractors
  end

  # def self.match_with_service_request(service_request)
  #   contractors = Contractor.within_range(service_request.zipcode, service_request.range)
  #                           .where("specializations && ARRAY[?]", service_request.required_specializations)
  #                           .distinct
  #
  #   contractors
  # end

  def all_responses
    ServiceResponse.joins(:service_request).where(service_requests: { contractor_id: id })
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

# Define a method to check if the contractor has already submitted a bid for a service request
  def submitted_bid_for?(service_request)
    bids.exists?(service_request_id: service_request.id)
  end

  # to disassociate all bids against a specific request,
  def disassociate_bids_from_request(request_id)
    bids_to_disassociate = bids.where(service_request_id: request_id)
    bids_to_disassociate.update_all(service_request_id: nil)
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

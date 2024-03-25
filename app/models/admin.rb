class Admin < User
  has_one :profile, foreign_key: 'user_id', dependent: :destroy
  accepts_nested_attributes_for :profile

  before_validation :populate_service_area

  delegate :name, :phone_number, :availability, :city, :state, :zipcode, :service_area,
           :website, :years_of_experience, :hourly_rate, :license_number, :insurance_provider,
           :insurance_policy_number, :have_insured, to: :profile

  delegate :type, to: :self, prefix: true, allow_nil: true


  def profile
    profile ||= Profile.find_or_initialize_by(user_id: id)
  end

  def populate_service_area
    if primary_address_county.present? && profile.present?
      profile.update(service_area: primary_address_county)
    else
      profile.update(service_area: nil)
    end
  end

  def primary_address_city
    primary_address&.city
  end

  def primary_address_zipcode
    primary_address&.zipcode
  end

  def primary_address_county
    primary_address&.county
  end

  def create_user_profile
    # Create a profile for the user if it doesn't exist
    self.create_profile unless self.profile
  end

  def primary_address
    profile&.addresses&.first
  end

  # Define a method to calculate regions within the zipcode_radius
  def regions_within_zipcode_radius
    return [] unless primary_address.present? && primary_address.zipcode.present?

    # Step 1: Geocode Admin's ZIP Code
    admin_coordinates = primary_address.location_coordinates

    if admin_coordinates
      # Step 2: Calculate Bounds of the Region
      radius = zipcode_radius || 10  # Example default radius in miles
      bounds = Geocoder::Calculations.bounding_box(admin_coordinates, radius)

      # Step 3: Fetch all ZIP codes within the bounding box
      all_zip_codes = fetch_zip_codes_within_bounds(bounds)

      # Step 4: Filter ZIP Codes within Radius
      regions = all_zip_codes.select do |zipcode|
        zipcode_coordinates = Geocoder.coordinates(zipcode)
        Geocoder::Calculations.distance_between(admin_coordinates, zipcode_coordinates) <= radius
      end

      # Step 5: Determine Regions
      regions
    else
      []
    end
  end

  private

  def fetch_zip_codes_within_bounds(bounds)
    # Example: Fetch ZIP codes from an external service or database
    # You'll need to replace this with your actual implementation
    # For example, you might call an API that provides ZIP code data within the bounding box
    # Or query a database table containing ZIP code data with their coordinates
    puts ">>>>>>>>>>>>.#{bounds.inspect}"
    # For demonstration purposes, return dummy data
    ['90001', '90002', '90003', '90210', '90211', '90212', '90401']
  end

end
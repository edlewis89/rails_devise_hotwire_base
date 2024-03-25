class Address < ApplicationRecord
  belongs_to :addressable, polymorphic: true, touch: true

  attribute :latitude, :float
  attribute :longitude, :float

  validates :state, presence: true
  validates :zipcode, presence: true

  geocoded_by :full_address
  after_validation :geocode, if: ->(obj) { obj.zipcode_changed? || obj.new_record? }

  after_commit :populate_coordinates_on_create, on: :create
  after_commit :flush_cache

  after_find :enqueue_city_county_update_if_coordinates_present


  def geocode_countrycodes_params
    # Assuming `country_code` is an attribute of the address model
    { countrycodes: country_code }
  end

  def full_address
    [street, city, state, country, country_code, zipcode].compact.join(', ')
  end

  def self.cached_find(id)
    Rails.cache.fetch([name, id]) { find(id) }
  end

  private

  def latitude_and_longitude_present?
    latitude.present? && longitude.present?
  end

  def flush_cache
    Rails.cache.delete([self.class.name, id])
  end

  def populate_coordinates_on_create
    return unless latitude.blank? || longitude.blank?

    Rails.logger.debug "Populating Lon/Lat LonLatUpdateWorker for Address ID: #{id}"
    LonLatUpdateWorker.perform_async(id)
  end

  def enqueue_city_county_update_if_coordinates_present
    return unless city.blank? || county.blank?
    
    if latitude_and_longitude_present?
      Rails.logger.debug "Enqueuing CityCountyUpdateWorker for Address ID: #{id}"
      CityCountyUpdateWorker.perform_async(id)
    end
  end
end

# class Address < ApplicationRecord
#   belongs_to :addressable, polymorphic: true, touch: true
#
#   attribute :latitude, :float
#   attribute :longitude, :float
#
#   validates :zipcode, presence: true
#
#   # Method to populate the city after validation
#   #after_validation :populate_city, on: :create, if: ->(obj){ obj.zipcode.present? && obj.city.blank? }
#   #after_validation :geocode, if: ->(obj){ obj.city_changed? || obj.zipcode_changed? || obj.new_record? }
#   after_validation :geocode_address, if: :zipcode_changed?
#   after_validation :populate_city, on: [:create, :update], if: ->(obj){ obj.zipcode.present? && obj.city.blank? }
#
#   after_commit :flush_cache
#   geocoded_by :full_address
#
#   def flush_cache
#     Rails.cache.delete([self.class.name, id])
#   end
#
#   def self.cached_find(id)
#     Rails.cache.fetch([name, id]) { find(id) }
#   end
#
#   def location_coordinates
#     Geocoder.coordinates(zipcode)
#   end
#
#   private
#
#   def geocode_address
#     return unless zipcode.present?
#
#     # Use Geocoder gem to fetch latitude and longitude based on the zipcode
#     geocoded_data = Geocoder.search(zipcode).first
#     return unless geocoded_data
#
#     self.latitude = geocoded_data.latitude
#     self.longitude = geocoded_data.longitude
#   end
#
#   def populate_city
#     result = Geocoder.search([latitude, longitude]).first
#
#     if result
#       city = result.city
#       state = result.state
#       zipcode = result.postal_code
#
#       save # Save the record after updating city and state
#       Rails.logger.debug "Geocoder Result for #{zipcode}: #{result.inspect}"
#     else
#       puts "No address found for the given coordinates."
#     end
#   end
#
#   def city_and_zipcode
#     [city, zipcode].compact.join(', ')
#   end
#
#   def full_address
#     [street, city, state, country, zipcode].compact.join(', ')
#   end
#
#   def geocode
#     Rails.logger.debug "Geocoding #{city_and_zipcode}"
#     super
#   end
# end


#
# class Address < ApplicationRecord
#   belongs_to :addressable, polymorphic: true, touch: true
#
#   # validates :state, presence: true
#   # validates :city, presence: true
#   validates :zipcode, presence: true
#
#   after_commit :flush_cache
#
#   def flush_cache
#     Rails.cache.delete([self.class.name, id])
#   end
#
#   def self.cached_find(id)
#     Rails.cache.fetch([name, id]) { find(id) }
#   end
#
#   # Additional attributes for geolocation
#   attribute :latitude, :float
#   attribute :longitude, :float
#
#   # Geocoding method to populate latitude and longitude based on city and ZIP code
#   geocoded_by :city_and_zipcode
#   after_validation :geocode, if: ->(obj){ obj.city_changed? || obj.zipcode_changed? || obj.new_record? }
#   #
#   # # Method to calculate service area based on radius in miles
#   # def within_service_area?(other_address, radius_in_miles)
#   #   return false if latitude.nil? || longitude.nil? || other_address.latitude.nil? || other_address.longitude.nil?
#   #
#   #   # Calculate distance between two points using Haversine formula
#   #   distance = Haversine.distance(latitude, longitude, other_address.latitude, other_address.longitude).to_miles
#   #
#   #   distance <= radius_in_miles
#   # end
#
#   # Method to generate city and ZIP code combination
#   def city_and_zipcode
#     [city, zipcode].compact.join(', ')
#   end
# end


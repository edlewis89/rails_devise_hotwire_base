class Address < ApplicationRecord
  belongs_to :addressable, polymorphic: true, touch: true

  #validates :city, presence: true
  #validates :state, presence: true
  #validates :city, presence: true
  validates :zipcode, presence: true

  after_commit :flush_cache

  def flush_cache
    Rails.cache.delete([self.class.name, id])
  end

  def self.cached_find(id)
    Rails.cache.fetch([name, id]) { find(id) }
  end

  # Additional attributes for geolocation
  attribute :latitude, :float
  attribute :longitude, :float

  # Geocoding method to populate latitude and longitude based on city and ZIP code
  #geocoded_by :city_and_zipcode
  #after_validation :geocode, if: ->(obj){ obj.city_changed? || obj.zipcode_changed? }

  # Method to calculate service area based on radius in miles
  def within_service_area?(other_address, radius_in_miles)
    return false if latitude.nil? || longitude.nil? || other_address.latitude.nil? || other_address.longitude.nil?

    # Calculate distance between two points using Haversine formula
    distance = Haversine.distance(latitude, longitude, other_address.latitude, other_address.longitude).to_miles

    distance <= radius_in_miles
  end

  # Method to generate city and ZIP code combination
  def city_and_zipcode
    [city, zipcode].compact.join(', ')
  end
end


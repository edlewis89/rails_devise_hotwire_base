# City and County Update Worker
class CityCountyUpdateWorker
  include Sidekiq::Worker

  def perform(address_id)
    address = Address.find_by(id: address_id)
    return unless address

    result = Geocoder.search([address.latitude, address.longitude]).first

    if result
      Rails.logger.error "CityCountyUpdateWorker: Geocoding result for address ID: #{address_id}: #{result.inspect}"
      address.update(city: result.city, county: result.county)
    else
      Rails.logger.error "No geocoding result found for address ID: #{address_id}"
    end
  end
end
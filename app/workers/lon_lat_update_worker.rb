# Lon/Lat Update Worker
class LonLatUpdateWorker
  include Sidekiq::Worker

  def perform(address_id)
    address = Address.find_by(id: address_id)
    return unless address

    result = Geocoder.search(address.zipcode, params: address.geocode_countrycodes_params).first

    if result
      address.update(latitude: result.latitude, longitude: result.longitude)
      Rails.logger.error "LonLatUpdateWorker: Geocoding result for address ID: #{address_id}: #{result.inspect}"
    else
      Rails.logger.error "No geocoding result found for address ID: #{address_id}"
    end
  end
end
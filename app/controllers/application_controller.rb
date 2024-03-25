class ApplicationController < ActionController::Base
  include Pundit::Authorization
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_analytics
  before_action :update_last_seen, if: :user_signed_in?
  before_action :set_carousel_ads, if: :user_signed_in?

  #after_action :verify_authorized, except: :index, unless: :devise_controller?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected

  private

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_back(fallback_location: root_path)
  end

  def full_messages messages
    if messages.any?
      messages.join("\n")
    else
      "something else went wrong!"
    end
  end

  def request_location
    if Rails.env.test? || Rails.env.development?
      Geocoder.search(ENV.fetch("GEOCODE_LOCAL_IP_ADDRESS", "127.0.0.1")).first
    else
      request.location
    end
  end

  def get_time_zone
    # if current_user&.primary_address
    #   latitude = current_user.primary_address.latitude
    #   longitude = current_user.primary_address.longitude
    #
    #   if latitude && longitude
    #     begin
    #       timezone = Timezone.fetch(lat: latitude, lng: longitude)
    #       timezone_name = timezone&.name
    #     rescue Timezone::Error => e
    #       Rails.logger.error "Error fetching timezone: #{e.message}"
    #     end
    #   else
    #     Rails.logger.error "Latitude or longitude missing for primary address"
    #   end
    # else
    #   Rails.logger.error "Primary address not found for current user"
    # end
  end


  def set_carousel_ads
    @user_timezone = get_time_zone
    @user_location = current_user&.primary_address_city || request_location&.city
    @services = Service.pluck(:name) # Retrieve all service names

    # Find advertisements matching the user's location (zipcode or city) for all services
    @ads_top = Advertisement.where(placement: :top)
                            .joins(:addresses)
                            .where("addresses.zipcode = ? OR addresses.city = ?", @user_location, @user_location)
                            .includes(:service)
                            .order(created_at: :desc) || []

    @ads_middle = Advertisement.where(placement: :middle)
                               .joins(:addresses)
                               .where("addresses.zipcode = ? OR addresses.city = ?", @user_location, @user_location)
                               .includes(:service)
                               .order(created_at: :desc) || []

    @ads_bottom = Advertisement.where(placement: :bottom)
                               .joins(:addresses)
                               .where("addresses.zipcode = ? OR addresses.city = ?", @user_location, @user_location)
                               .includes(:service)
                               .order(created_at: :desc) || []

    @ads_left = Advertisement.where(placement: :left)
                             .joins(:addresses)
                             .where("addresses.zipcode = ? OR addresses.city = ?", @user_location, @user_location)
                             .includes(:service)
                             .order(created_at: :desc) || []

    @ads_right = Advertisement.where(placement: :right)
                              .joins(:addresses)
                              .where("addresses.zipcode = ? OR addresses.city = ?", @user_location, @user_location)
                              .includes(:service)
                              .order(created_at: :desc) || []

    @ads_regular = Advertisement.where(advertisement_type: :regular)
                              .joins(:addresses)
                              .where("addresses.zipcode = ? OR addresses.city = ?", @user_location, @user_location)
                              .includes(:service)
                              .order(created_at: :desc) || []

    @ads_featured = Advertisement.where(advertisement_type: :featured)
                              .joins(:addresses)
                              .where("addresses.zipcode = ? OR addresses.city = ?", @user_location, @user_location)
                              .includes(:service)
                              .order(created_at: :desc) || []

  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:role])
  end

  def update_last_seen
    current_user.update(last_seen_at: Time.current)
  end

  def set_analytics
    # Enqueue the RedisService worker
    RedisService.perform_async

    # Update bid counts for service requests
    RedisService.update_service_requests_with_all_bids

    #RedisService.perform_async(:update_active_users_count)

    # Fetch analytics data from Redis after the worker has updated the values
    #@login_count = RedisService.get_active_users_count
    @service_request_count = RedisService.get_service_request_count
    @bid_count = RedisService.get_bid_count
    @contractor_count = RedisService.get_contractor_count
    @homeowner_count = RedisService.get_homeowner_count
    @licensed_contractor_count = RedisService.get_licensed_contractor_count
    # Fetch service request bids
    @service_request_bids = {}
    ServiceRequest.find_each do |service_request|
      @service_request_bids[service_request.id] = RedisService.get_bids_for_service_request(service_request.id)
    end

    # Fetch have_license attribute from user profiles using the delegate
    # licensed_contractors = User.licensed_contractors
    @licensed_contractor_count_with_license = @licensed_contractor_count

    # Calculate count of licensed contractors without a license
    @licensed_contractor_count_without_license = [@licensed_contractor_count - @contractor_count, 0].max

    @active_users_count = RedisService.get_active_users_count
  end
end

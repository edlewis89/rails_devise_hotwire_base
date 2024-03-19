class ApplicationController < ActionController::Base
  include Pundit::Authorization
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_analytics

  #after_action :verify_authorized, except: :index, unless: :devise_controller?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  #before_action :set_ads

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

  def set_ads
    @user_location = current_user&.primary_address_city || request.location.city
    @services = Service.pluck(:name) # Retrieve all service names

    # Find advertisements matching the user's location (zipcode or city) for all services
    @ads = Advertisement.joins(:addresses)
                        .where("addresses.zipcode = ? OR addresses.city = ?", @user_location, @user_location)
                        .includes(:service)
                        .order(created_at: :desc) || []
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:role])
  end

  def set_analytics
    # Update Redis counters

    # Fetch updated counters
    RedisService.update_analytics
    @login_count = RedisService.get_active_users_count
    @service_request_count = RedisService.get_service_request_count
    @service_response_count = RedisService.get_service_response_count
    @contractor_count = RedisService.get_contractor_count
    @homeowner_count = RedisService.get_homeowner_count
    @licensed_contractor_count = RedisService.get_licensed_contractor_count

    # Fetch have_license attribute from user profiles using the delegate
    #licensed_contractors = User.licensed_contractors
    @licensed_contractor_count_with_license = @licensed_contractor_count

    @licensed_contractor_count_without_license = (@licensed_contractor_count - @contractor_count).abs
  end
end

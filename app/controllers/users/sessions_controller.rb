# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end


  def create
    super do |resource|
      # After successful login, set the analytics data
      RedisService.increment_active_users_count
      #set_analytics
      # reset_analytics
      # set_analytics
      #
      # # Redirect to the appropriate page
      # redirect_to root_path
    end
  end

  # DELETE /resource/sign_out
  def destroy
    super do |resource|
      # After successful logout, set the analytics data
      RedisService.decrement_active_users_count
      #
      # reset_analytics
      # set_analytics
      #
      # # Redirect to the appropriate page
      # redirect_to root_path
    end
  end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
  private

  def reset_analytics
    # Reset analytics data to initial values
    # $redis.incrby('login_count', 1)
    # Reset other analytics data as needed
  end

  def set_analytics

    licensed_contractors = User.licensed_contractors
    @licensed_contractor_count_with_license = licensed_contractors.count { |user| user.has_license? }
    #@licensed_contractors_with_license = licensed_contractors.select { |user| user.has_license? }
    #@licensed_contractor_count_without_license = @licensed_contractor_count - @licensed_contractor_count_with_license
    # Set analytics data based on the current state of the system
    # Set service_request_count
    $redis.set('service_request_count', ServiceRequest.count)

    # Set contractor_count
    $redis.set('contractor_count', licensed_contractors.count)

    # Set licensed_contractor_count
    $redis.set('licensed_contractor_count', @licensed_contractor_count_with_license)
    # Set other analytics data as needed
  end
end

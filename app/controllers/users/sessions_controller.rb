# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  #after_action :update_last_seen, only: :create
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
      #update_last_seen(resource)
    end
  end

  # DELETE /resource/sign_out
  def destroy
    super do |resource|
      #update_last_seen(resource)
    end
  end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end

  private

  # def update_last_seen
  #   binding.pry
  #   current_user.update_attribute(:last_seen_at, Time.current) if current_user
  # end
end

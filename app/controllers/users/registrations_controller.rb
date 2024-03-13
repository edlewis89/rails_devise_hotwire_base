# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :authenticate_user!
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  def create
    resource = create_resource(resource)

    if resource.save
      resource.send_confirmation_instructions  # Send confirmation email
      UserRegistrationService.call(resource) # Send Greeting Email

      redirect_to after_sign_up_path_for(resource), notice: 'Confirmation email sent. Please check your email to confirm your account.'
    else
      flash[:alert] = resource.errors.full_messages.join(', ')
      render :new
    end
  end

  # GET /resource/edit
  def edit
    # # Call super to run the default edit action
    # super do |resource|
    #   # Assign the resource to @user for use in the view
    #   @user = resource
    #   # Check if devise_mapping is available
    #   # if defined?(devise_mapping) && devise_mapping.validatable?
    #   #   # Set minimum password length
    #   #   @minimum_password_length = resource_class.password_length.min
    #   # end
    # end
  end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end

  def create_resource(hash = nil)
    hash ||= sign_up_params
    role = hash[:role]

    case role
    when 'property_owner'
      resource = Homeowner.new(hash.merge(subscription_level: 'basic'))
    when 'service_provider'
      resource = Contractor.new(hash.merge(subscription_level: 'premium'))
    else
      resource = User.new(hash)
    end

    self.resource = resource
  end

  def after_sign_up_path_for(resource)
    if resource.confirmed?
      # Redirect to a specific page after successful sign-up
      root_path
    else
      # If the user is not confirmed yet, redirect to the confirmation page
      new_user_registration_path
    end
  end

  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation, :role)
  end
end


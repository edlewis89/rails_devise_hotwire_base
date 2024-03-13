class AdManagersController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :authorize_user, except: %i[index show]
  before_action :set_ad_manager, only: %i[ show edit update destroy ]

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  # GET /ad_managers or /ad_managers.json
  def index
    begin
      @ad_managers = AdManager.find(current_user.id)
    rescue ActiveRecord::RecordNotFound
      # If the Ad Manager record for the current user is not found, handle the error gracefully
      redirect_to root_path, alert: "Ad Manager record not found."
    end
  end

  # GET /ad_managers/1 or /ad_managers/1.json
  def show
  end

  # GET /ad_managers/new
  def new
    @ad_manager = AdManager.new
  end

  # GET /ad_managers/1/edit
  def edit
    @ad_manager = AdManager.find(params[:id])
    @profile = @ad_manager.profile
    # Only allowing to update 1 address for now.
    @address = @profile&.addresses&.first || Address.new

    respond_to do |format|
      format.html # Render HTML template for editing
      format.turbo_stream { render turbo_stream: turbo_stream.replace(@ad_manager, partial: "ad_managers/form", locals: { ad_manager: @ad_manager }) }
    end
  end

  # POST /ad_managers or /ad_managers.json
  def create
    @ad_manager = AdManager.new(ad_manager_params)

    respond_to do |format|
      if @ad_manager.save
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update('new_ad_manager', partial: "ad_managers/form", locals: { ad_manager: AdManager.new }),
            turbo_stream.prepend('ad_managers', partial: "ad_manager/ad_manager", locals: { ad_manager: @ad_manager }),
            turbo_stream.update("flash", partial: "shared/flash", locals: { msg_type: :alert, message: "Ad Manager #{@ad_manager.email} Created" })
          ]
        end
        format.html { redirect_to ad_manager_url(@ad_manager), notice: "Ad Manager was successfully created." }
        format.json { render :show, status: :created, location: @ad_manager }
      else
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update('new_ad_manager', partial: "ad_managers/form", locals: { ad_manager: @ad_manager })
          ]
        end
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @ad_manager.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ad_managers/1 or /ad_managers/1.json
  def update
    @ad_manager = AdManager.find(params[:id])

    respond_to do |format|
      if @ad_manager.update(ad_manager_params) && @ad_manager.profile&.update(profile_params)
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update(@ad_manager, partial: "ad_managers/ad_manager", locals: { ad_manager: @ad_manager }),
            turbo_stream.replace("flash", partial: "shared/flash", locals: { msg_type: :alert, message: "Ad Manager #{@ad_manager.name} Updated" })
          ]
        end
        format.html { redirect_to ad_manager_url(@ad_manager), notice: "Ad Manager and profile was successfully updated." }
        format.json { render :show, status: :ok, location: @ad_manager }
      else

        ad_manager_errors = @ad_manager.errors.full_messages
        profile_errors = @ad_manager.profile&.errors&.full_messages || []
        all_errors = ad_manager_errors + profile_errors

        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update(@ad_manager, partial: "ad_managers/form", locals: { ad_manager: @ad_manager }),
            turbo_stream.update("flash", partial: "shared/flash", locals: { msg_type: :error, message: full_messages(all_errors) })
          ]
        end
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @ad_manager.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ad_managers/1 or /ad_managers/1.json
  def destroy
    begin
      @ad_manager.destroy!
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove(@ad_manager),
            turbo_stream.update("flash", partial: "shared/flash", locals: { msg_type: :alert, message: "Ad Manager deleted" })
          ]

        end
        format.html { redirect_to ad_managers_url, notice: "Ad Manager was successfully destroyed." }
        format.json { head :no_content }
      end

    rescue Elasticsearch::Transport::Transport::Errors::NotFound => e
      Rails.logger.error("Document not found in Elasticsearch: #{e.message}")
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove(@ad_manager),
            turbo_stream.update("flash", partial: "shared/flash", locals: { msg_type: :alert, message: "Ad Manager deleted" })
          ]

        end
        format.html { redirect_to ad_managers_url, notice: "Ad Manager was successfully destroyed." }
        format.json { head :no_content }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def authorize_user
    ad_manager = @ad_manager || AdManager
    authorize ad_manager
  end

  def set_ad_manager
    @ad_manager = AdManager.find(params[:id])
  end

  # Permit @ad_manager parameters
  def ad_manager_params
    params.require(:ad_manager).permit(:id, :role, :subscription_level, :active, :public, :email, profile_attributes: [
      :id, :user_id, :image_data, :name, :years_of_experience, :certifications_array, :hourly_rate,
      :specializations_array, :languages_array, :have_license, :license_number,
      :phone_number, :website, :service_area, :have_insurance, :insurance_provider,
      :insurance_policy_number, addresses_attributes: [:addressable_id, :city, :state, :zipcode, :_destroy]
    ])
  end

  # Permit profile parameters
  def profile_params
    params.require(:ad_manager).require(:profile_attributes).permit(
      :id, :user_id, :image_data, :name, :years_of_experience, :certifications_array, :hourly_rate,
      :specializations_array, :languages_array, :have_license, :license_number,
      :phone_number, :website, :service_area, :have_insurance, :insurance_provider,
      :insurance_policy_number, addresses_attributes: [:id, :addressable_id, :city, :state, :zipcode, :_destroy]
    )
  end

  def query_params
    params.permit(:query)
  end

  def record_not_found
    redirect_to root_path, alert: "Ad Manager record not found."
  end
end

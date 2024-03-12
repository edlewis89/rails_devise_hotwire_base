class AdminsController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :authorize_user, except: %i[index show]
  before_action :set_admin, only: %i[ show edit update destroy ]

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  # GET /admins or /admins.json
  def index
    begin
      @admins = Admin.find(current_user.id)
    rescue ActiveRecord::RecordNotFound
      # If the Admin record for the current user is not found, handle the error gracefully
      redirect_to root_path, alert: "Admin record not found."
    end
  end
  
  # GET /admins/1 or /admins/1.json
  def show
  end

  # GET /admins/new
  def new
    @admin = Admin.new
  end

  # GET /admins/1/edit
  def edit
    @admin = Admin.find(params[:id])
    @profile = @admin.profile
    # Only allowing to update 1 address for now.
    @address = @profile&.addresses&.first || Address.new

    respond_to do |format|
      format.html # Render HTML template for editing
      format.turbo_stream { render turbo_stream: turbo_stream.replace(@admin, partial: "admins/form", locals: { admin: @admin }) }
    end
  end

  # POST /admins or /admins.json
  def create
    @admin = Admin.new(admin_params)

    respond_to do |format|
      if @admin.save
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update('new_admin', partial: "admins/form", locals: { admin: Admin.new }),
            turbo_stream.prepend('admins', partial: "admins/admin", locals: { admin: @admin }),
            turbo_stream.update("flash", partial: "shared/flash", locals: { msg_type: :alert, message: "Admin #{@admin.email} Created" })
          ]
        end
        format.html { redirect_to admin_url(@admin), notice: "Admin was successfully created." }
        format.json { render :show, status: :created, location: @admin }
      else
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update('new_admin', partial: "admins/form", locals: { admin: @admin })
          ]
        end
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @admin.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admins/1 or /admins/1.json
  def update
    @admin = Admin.find(params[:id])

    respond_to do |format|
      if @admin.update(admin_params) && @admin.profile&.update(profile_params)
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update(@admin, partial: "admins/admin", locals: { admin: @admin }),
            turbo_stream.replace("flash", partial: "shared/flash", locals: { msg_type: :alert, message: "Admin #{@admin.name} Updated" })
          ]
        end
        format.html { redirect_to admin_url(@admin), notice: "Admin and profile was successfully updated." }
        format.json { render :show, status: :ok, location: @admin }
      else

        admin_errors = @admin.errors.full_messages
        profile_errors = @admin.profile&.errors&.full_messages || []
        all_errors = admin_errors + profile_errors

        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update(@admin, partial: "admins/form", locals: { admin: @admin }),
            turbo_stream.update("flash", partial: "shared/flash", locals: { msg_type: :error, message: full_messages(all_errors) })
          ]
        end
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @admin.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admins/1 or /admins/1.json
  def destroy
    begin
      @admin.destroy!
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove(@admin),
            turbo_stream.update("flash", partial: "shared/flash", locals: { msg_type: :alert, message: "Admin deleted" })
          ]

        end
        format.html { redirect_to admins_url, notice: "Admin was successfully destroyed." }
        format.json { head :no_content }
      end

    rescue Elasticsearch::Transport::Transport::Errors::NotFound => e
      Rails.logger.error("Document not found in Elasticsearch: #{e.message}")
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove(@admin),
            turbo_stream.update("flash", partial: "shared/flash", locals: { msg_type: :alert, message: "Admin deleted" })
          ]

        end
        format.html { redirect_to admins_url, notice: "Admin was successfully destroyed." }
        format.json { head :no_content }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def authorize_user
    admin = @admin || Admin
    authorize admin
  end

  def set_admin
    @admin = Admin.find(params[:id])
  end

  # Permit admin parameters
  def admin_params
    params.require(:admin).permit(:active, :public, :email, profile_attributes: [
      :id, :user_id, :image_data, :name, :years_of_experience, :certifications_array, :hourly_rate,
      :specializations_array, :languages_array, :have_license, :license_number,
      :phone_number, :website, :service_area, :have_insurance, :insurance_provider,
      :insurance_policy_number, addresses_attributes: [:addressable_id, :city, :state, :zipcode, :_destroy]
    ])
  end

  # Permit profile parameters
  def profile_params
    params.require(:admin).require(:profile_attributes).permit(
      :id, :user_id, :image_data, :name, :years_of_experience, :certifications_array, :hourly_rate,
      :specializations_array, :languages_array, :have_license, :license_number,
      :phone_number, :website, :service_area, :have_insurance, :insurance_provider,
      :insurance_policy_number, addresses_attributes: [:addressable_id, :city, :state, :zipcode, :_destroy]
    )
  end

  def query_params
    params.permit(:query)
  end

  def record_not_found
    redirect_to root_path, alert: "Here Admin record not found."
  end
end

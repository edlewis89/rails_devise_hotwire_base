class ContractorsController < ApplicationController

  before_action :authenticate_user!, except: %i[index show]
  before_action :authorize_user, except: %i[index show]
  before_action :set_contractor, only: %i[ show edit update destroy ]

  #before_action :ensure_index_exists, only: %i[ create update destroy ]

  # GET /contractors or /contractors.json
  def index
    if query_params.key?(:query) && query_params[:query].present?
      contractor_ids = []

      # Search Elasticsearch for profiles matching the query
      es_response = Profile.search_in_elastic(query_params[:query]).response
  
      # Extract contractor IDs from Elasticsearch response
      if es_response.present? && es_response['hits'].present? && es_response['hits']['hits'].present?
        es_response['hits']['hits'].each do |hit|
          profile_id = hit['_id']
          profile = Profile.find(profile_id)
          contractor_ids << profile.user_id if profile.present?
        end
      end
      
      # Fetch contractors based on the IDs retrieved from Elasticsearch
      contractors = Contractor.where(id: contractor_ids)
      
      # Paginate the contractors
      @contractors = contractors.paginate(page: params[:page] || 1, per_page: 5)
    else
      # Handle the case where the Elasticsearch search returned nil
      @contractors = Contractor.order(created_at: :desc).paginate(page: params[:page] || 1, per_page: 5)
    end
  end
  
  # GET /contractors/1 or /contractors/1.json
  def show
  end

  # GET /contractors/new
  def new
    @contractor = Contractor.new
  end

  # GET /contractors/1/edit
  def edit
    @contractor = Contractor.find(params[:id])
    respond_to do |format|
      format.html # Render HTML template for editing
      format.turbo_stream { render turbo_stream: turbo_stream.replace(@contractor, partial: "contractors/form", locals: { contractor: @contractor }) }
    end
  end

  # POST /contractors or /contractors.json
  def create
    @contractor = Contractor.new(contractor_params)

    respond_to do |format|
      if @contractor.save
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update('new_contractor', partial: "contractors/form", locals: { contractor: Contractor.new }),
            turbo_stream.prepend('contractors', partial: "contractors/contractor", locals: { contractor: @contractor }),
            turbo_stream.update("flash", partial: "shared/flash", locals: { msg_type: :alert, message: "Contract #{@contractor.email} Created" })
          ]
        end
        format.html { redirect_to contractor_url(@contractor), notice: "Contractor was successfully created." }
        format.json { render :show, status: :created, location: @contractor }
      else
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update('new_contractor', partial: "contractors/form", locals: { contractor: @contractor })
          ]
        end
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @contractor.errors, status: :unprocessable_entity }

        #render_flash(:alert, full_messages(@contractor.errors.full_messages))
      end
    end
  end

  # PATCH/PUT /contractors/1 or /contractors/1.json
  def update
    respond_to do |format|
      if @contractor.update(contractor_params) && @contractor.profile.update(profile_params)
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update(@contractor,
                                partial: "contractors/contractor",
                                locals: { contractor: @contractor }),
            turbo_stream.update("flash", partial: "shared/flash", locals: { msg_type: :alert, message: "Contract #{@contractor.name} Updated" })
          ]
        end
        format.html { redirect_to contractor_url(@contractor), notice: "Contractor and profile was successfully updated." }
        format.json { render :show, status: :ok, location: @contractor }
      else
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update(@contractor,
                                partial: "contractors/form",
                                locals: { contractor: @contractor }),
            turbo_stream.update("flash", partial: "shared/flash", locals: { msg_type: :error, message: full_messages(@contractor.errors.full_messages) })
          ]
        end
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @contractor.errors, status: :unprocessable_entity }

        #render_flash(:alert, full_messages(@contractor.errors.full_messages))
      end
    end
  end

  # DELETE /contractors/1 or /contractors/1.json
  def destroy
    begin
      @contractor.destroy!
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove(@contractor),
            turbo_stream.update("flash", partial: "shared/flash", locals: { msg_type: :alert, message: "Contractor deleted" })
          ]

        end
        format.html { redirect_to contractors_url, notice: "Contractor was successfully destroyed." }
        format.json { head :no_content }
      end

    rescue Elasticsearch::Transport::Transport::Errors::NotFound => e
      Rails.logger.error("Document not found in Elasticsearch: #{e.message}")
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove(@contractor),
            turbo_stream.update("flash", partial: "shared/flash", locals: { msg_type: :alert, message: "Contractor deleted" })
          ]

        end
        format.html { redirect_to contractors_url, notice: "Contractor was successfully destroyed." }
        format.json { head :no_content }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def authorize_user
    contractor = @contractor || Contractor
    authorize contractor
  end
  def set_contractor
    @contractor = Contractor.find(params[:id])
  end

  def contractor_params
    params.require(:contractor).permit(:email, :role, :verified, :active, :public) # Add other attributes as needed
  end

  # Only allow a list of trusted parameters through.
  def profile_params
    params.require(:profile).permit(
      :name,
      :description,
      :phone_number,
      :city,
      :state,
      :zipcode,
      :website,
      :license_number,
      :insurance_provider,
      :insurance_policy_number,
      :have_insurance,
      :have_license,
      :service_area,
      :years_of_experience,
      :specializations,
      :certifications,
      :languages_spoken,
      :hourly_rate,
      :image,
      :specializations_array,
      :languages_array,
      :certifications_array,
      # Add other attributes here
    )
  end

  def query_params
    params.permit(:query)
  end
end

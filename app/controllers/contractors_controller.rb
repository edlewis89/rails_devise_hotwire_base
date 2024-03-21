class ContractorsController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :authorize_user, except: %i[index show]
  before_action :set_contractor, only: %i[show edit update destroy]

  def index
    authorize Contractor, :search?
    query_params.key?(:query) && query_params[:query].present? ? search_contractors : load_contractors
  end

  def show
  end

  def new
    @contractor = Contractor.new
    @contractor.profile.addresses.build
  end

  def edit
    @profile = @contractor.profile
    @profile.addresses.build unless @profile.addresses.any?
  end

  def create
    @contractor = Contractor.new(contractor_params)
    if @contractor.save
      flash_message = "Contractor was successfully created."
      render_success_message(flash_message)
    else
      render_error_message(@contractor)
    end
  end

  def update
    @profile = @contractor.profile
    if @contractor.update(contractor_params) && @profile.update(profile_params)
      flash_message = "Contractor and profile were successfully updated."
      render_success_message(flash_message)
    else
      render_error_message(@contractor)
    end
  end

  def destroy
    @contractor.destroy!
    flash_message = "Contractor deleted"
    render_success_message(flash_message)
  rescue Elasticsearch::Transport::Transport::Errors::NotFound => e
    Rails.logger.error("Document not found in Elasticsearch: #{e.message}")
    render_success_message(flash_message)
  end


  def autocomplete
    binding.pry
    term = params[:term]
    @contractors = Profile.search_in_elastic(term)
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace('contractors', partial: 'contractors/autocomplete', locals: { contractors: @contractors }) }
    end
  end

  private

  def search_contractors
    es_response = Profile.search_in_elastic(query_params[:query]).response
    profile_ids = []
    if es_response.present? && es_response['hits'].present? && es_response['hits']['hits'].present?
      es_response['hits']['hits'].each do |hit|
        profile_ids << hit['_id'] if hit['_source']['user_type'] == 'Contractor'
      end
    end
    contractors = Contractor.joins(:profile).where(profiles: { id: profile_ids.map(&:to_i) })
    @contractors = contractors.paginate(page: params[:page] || 1, per_page: 5)
    render_index_template
  end

  def load_contractors
    @contractors = Contractor.paginate(page: params[:page] || 1, per_page: 5)
    render 'index'
  end

  def render_index_template
    render 'index'
  end

  def authorize_user
    authorize (@contractor || Contractor)
  end

  def set_contractor
    @contractor = Contractor.find(params[:id])
  end

  def contractor_params
    params.require(:contractor).permit(:id, :role, :subscription_level, :active, :public, :email, profile_attributes: [
      :id, :user_id, :image_data, :name, :years_of_experience, :certifications_array, :hourly_rate,
      :specializations_array, :languages_array, :have_license, :license_number,
      :phone_number, :website, :service_area, :have_insurance, :insurance_provider,
      :insurance_policy_number, addresses_attributes: [:id, :addressable_id, :city, :state, :zipcode, :_destroy]
    ])
  end

  def profile_params
    params.require(:contractor).require(:profile_attributes).permit(
      :id, :user_id, :role, :subscription_level, :image_data, :name, :years_of_experience, :certifications_array, :hourly_rate,
      :specializations_array, :languages_array, :have_license, :license_number,
      :phone_number, :website, :service_area, :have_insurance, :insurance_provider,
      :insurance_policy_number, addresses_attributes: [:id, :addressable_id, :city, :state, :zipcode, :_destroy]
    )
  end

  def query_params
    params.permit(:query)
  end

  def render_success_message(message)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update('new_contractor', partial: "contractors/form", locals: { contractor: Contractor.new }),
          turbo_stream.prepend('contractors', partial: "contractors/contractor", locals: { contractor: @contractor }),
          turbo_stream.update("flash", partial: "shared/notices", locals: { msg_type: :alert, message: message })
        ]
      end
      format.html { redirect_to contractor_url(@contractor), notice: message }
      format.json { render :show, status: :created, location: @contractor }
    end
  end

  def render_error_message(model)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace('form-container', partial: "contractors/form", locals: { contractor: model }),
          turbo_stream.replace("form-container", partial: "shared/notices", locals: { msg_type: :error, message: full_messages(model.errors.full_messages) })
        ]
      end
      format.html { render :new, status: :unprocessable_entity }
      format.json { render json: model.errors, status: :unprocessable_entity }
    end
  end
end
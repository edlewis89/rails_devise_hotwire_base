class ContractorsController < ApplicationController
  include ContractorsHelper

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
    @contractor.profile.addresses.new
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
      update_error_response(@contractor, @profile) # Pass both models
      #render_error_message(@contractor)
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
    term = params[:q]
    @contractor_options = search_contractors_for_options_select(term)
    #@contractor_options = results[:contractor_options].compact
    puts ">>>>> #{@contractor_options}"
    render layout: false
    # respond_to do |format|
    #   format.turbo_stream { render turbo_stream: turbo_stream.replace('results', partial: 'contractors/autocomplete', locals: { contractor_options: @contractor_options[:contractor_options] }) }
    # end
  end

  private

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
    params.require(:contractor).permit(:id, :role, :subscription_level, :zipcode_radius, :active, :public, :email, profile_attributes: [
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


  def update_error_response(contractor, profile)
    if contractor.errors.any?
      render_error_message(contractor)
    else
      render_error_message(profile)
    end
  end

  def render_error_message(model)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace('contractor_container', partial: "contractors/form", locals: { contractor: model }),
          turbo_stream.replace("contractor_container", partial: "shared/notices", locals: { msg_type: :error, message: full_messages(model.errors.full_messages) })
        ]
      end
      format.html { render :edit, status: :unprocessable_entity }
      format.json { render json: model.errors, status: :unprocessable_entity }
    end
  end

  # def render_error_response(model)
  #   respond_to do |format|
  #     format.html { render :new, status: :unprocessable_entity }
  #     format.json { render json: model.errors, status: :unprocessable_entity }
  #   end
  # end
  #
  # def render_success_response(model, success_message)
  #   respond_to do |format|
  #     format.html { redirect_to model, notice: success_message }
  #     format.json { render :show, status: :created, location: model }
  #   end
  # end


  # def render_error_message(model)
  #   binding.pry
  #   respond_to do |format|
  #     format.html { render :edit, status: :unprocessable_entity }
  #     format.json { render json: model.errors, status: :unprocessable_entity }
  #   end
  # end

  # def update_success_response(model, success_message)
  #   respond_to do |format|
  #     format.html { redirect_to model, notice: success_message }
  #     format.json { render :show, status: :ok, location: model }
  #   end
  # end

end
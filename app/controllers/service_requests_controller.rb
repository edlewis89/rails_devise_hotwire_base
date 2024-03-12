class ServiceRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user, except: %i[index show]
  before_action :set_service_request, only: [:show, :edit, :update, :destroy]

  # GET /service_requests
  # GET /service_requests.json
  def index
    if current_user.property_owner?
      @service_requests = current_user.service_requests.order(created_at: :desc).paginate(page: params[:page], per_page: 5)
    else
      @service_requests = ServiceRequest.order(created_at: :desc).paginate(page: params[:page], per_page: 5)
    end
   end

  # GET /service_requests/1
  # GET /service_requests/1.json
  def show
    redirect_to service_requests_path # Redirect to index page
    # or
    # render plain: "No content available", status: :no_content # Render plain text
  end

  # GET /service_requests/new
  def new
    @service_request = current_user.service_requests.build
  end

  # GET /service_requests/1/edit
  def edit
    @service_request = ServiceRequest.find(params[:id])
    respond_to do |format|
      format.html # Render HTML template for editing
      format.turbo_stream { render turbo_stream: turbo_stream.replace(@service_request, partial: "service_requests/form", locals: { service_request: @service_request }) }
    end
  end

  # POST /service_requests
  # POST /service_requests.json
  def create
    binding.pry
    @service_request = current_user.service_requests.build(service_request_params)
    @service_request.homeowner_type = 'Homeowner'

    # Assign selected service IDs to the ServiceRequest object
    @service_request.service_ids = service_request_params[:service_ids]

    if @service_request.save
      redirect_to @service_request, notice: "Service request was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
    # respond_to do |format|
    #   if @service_request.save
    #     format.turbo_stream do
    #       render turbo_stream: [
    #         turbo_stream.update('new_service_request', partial: "service_requests/form", locals: { service_request: ServiceRequest.new }),
    #         turbo_stream.prepend('service_requests', partial: "service_requests/service_request", locals: { service_request: @service_request }),
    #         turbo_stream.update("flash", partial: "shared/flash", locals: { msg_type: :alert, message: "Service request created" })
    #       ]
    #     end
    #
    #     format.html { redirect_to service_requests_path, notice: "Service request was successfully created." }
    #     format.json { render :show, status: :created, location: @service_request }
    #   else
    #     format.turbo_stream do
    #       render turbo_stream: [
    #         turbo_stream.update('new_service_request', partial: "service_requests/form", locals: { service_request: @service_request })
    #       ]
    #     end
    #     format.html { render :new, status: :unprocessable_entity }
    #     format.json { render json: @service_request.errors, status: :unprocessable_entity }
    #
    #     #render_flash(:alert, full_messages(@contractor.errors.full_messages))
    #   end
    # end
    #
    # respond_to do |format|
    #   if # logic to determine if the response was successful
    #   format.html { redirect_to service_requests_path, notice: 'Your service request was successfully submitted.' }
    #     format.json { render json: @service_request, status: :created, location: @service_request }
    #   else
    #     format.html { render :respond }
    #     format.json { render json: @service_request.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # PATCH/PUT /service_requests/1
  # PATCH/PUT /service_requests/1.json
  def update
    if @service_request.update(service_request_params)
      redirect_to @service_request, notice: 'Service request was successfully updated.'
    else
      render :edit
    end

    # respond_to do |format|
    #   if @service_request.update(service_request_params)
    #     format.html { redirect_to @service_request, notice: 'Service request was successfully updated.' }
    #     format.json { render :show, status: :ok, location: @service_request }
    #   else
    #     format.html { render :edit }
    #     format.json { render json: @service_request.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # DELETE /service_requests/1
  # DELETE /service_requests/1.json
  def destroy
    @service_request.destroy
    redirect_to service_requests_url, notice: 'Service request was successfully destroyed.'

    # @service_request.destroy
    # respond_to do |format|
    #   format.html { redirect_to service_requests_url, notice: 'Service request was successfully destroyed.' }
    #   format.json { head :no_content }
    # end
  end

  def respond
    @service_request = ServiceRequest.find(params[:id])
    @service_response = ServiceResponse.new # Initialize a new ServiceResponse object

    # Logic to respond to the service request
    respond_to do |format|
      format.html # Render HTML template (if available)
      format.json { render json: @service_request }
      # Add other formats as needed
    end
  end

  private

  def authorize_user
    service_request = @service_request || ServiceRequest
    authorize service_request
  end

  def set_service_request
    @service_request = ServiceRequest.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def service_request_params
    params.require(:service_request).permit(:title, :image_data, :description, :status, :range, :location, :budget, :timeline, :message, :proposed_cost, :estimated_completion_date, service_ids: [])
  end
end
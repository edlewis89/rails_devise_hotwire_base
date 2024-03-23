class ServiceRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user, except: %i[index show bid]
  before_action :set_service_request, only: [:show, :edit, :update, :destroy, :bid]
  before_action :set_active_storage_url_options, only: [:edit, :update]
  before_action :set_bids, only: [:show]

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
  end

  # GET /service_requests/new
  def new
    @service_request = ServiceRequest.new
  end

  # GET /service_requests/1/edit
  def edit
    @service_request = ServiceRequest.find(params[:id])
    @existing_images = @service_request.images
    respond_to do |format|
      format.html # Render HTML template for editing
      format.turbo_stream { render turbo_stream: turbo_stream.replace(@service_request, partial: "service_requests/form", locals: { service_request: @service_request }) }
    end
  end

  # POST /service_requests
  # POST /service_requests.json
  def create
    @service_request = current_user.service_requests.build(service_request_params)
    @service_request.status = :open # Set the status to open
    # Assign selected service IDs to the ServiceRequest object
    @service_request.service_ids = service_request_params[:service_ids]

    respond_to do |format|
      if @service_request.save
        format.html { redirect_to @service_request, notice: "Service request was successfully created." }
        format.json { render :show, status: :created, location: @service_request }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @service_request.errors, status: :unprocessable_entity }
      end
    end
  end


  # PATCH/PUT /service_requests/1
  # PATCH/PUT /service_requests/1.json
  def update
    @service_request = ServiceRequest.find(params[:id])

    # Handle image removal
    if params[:remove_images]
      params[:remove_images].each do |image_id|
        image = @service_request.images.find_by(id: image_id)
        image.purge_later if image.present?
      end
    end

    # Update service_request_params based on image removal
    updated_service_request_params = if params[:remove_images]
                                       # Remove the images array from the service_request params
                                       service_request_params.except(:images)
                                     else
                                       service_request_params
                                     end

    if @service_request.update(updated_service_request_params)
      redirect_to @service_request, notice: 'Service request was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /service_requests/1
  # DELETE /service_requests/1.json
  def destroy
    @service_request.destroy
    redirect_to service_requests_url, notice: 'Service request was successfully destroyed.'
  end

  def bid
    @service_request = ServiceRequest.find(params[:id])
    if @service_request
      @bid = Bid.new(service_request: @service_request) # Associate the bid with the service request
      respond_to do |format|
        format.html { redirect_to service_request_bids_path(@service_request) }
        format.json { render json: @bid }
      end
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

  def set_active_storage_url_options
    ActiveStorage::Current.url_options = Rails.application.config.action_mailer.default_url_options
  end

  # Only allow a list of trusted parameters through.
  def service_request_params
    params.require(:service_request).permit(:id, :title, :description, :status, :zipcode_radius, :location, :budget, :timeline, :due_date, service_ids: [], images: [], remove_images: [])
  end

  def set_bids
    @bids = @service_request.bids
  end
end
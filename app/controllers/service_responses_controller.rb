class ServiceResponsesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user, except: [:index]

  def show
    @service_response = ServiceResponse.find(params[:id])
  end

  def index
    @service_request = ServiceRequest.find(params[:service_request_id])
    @service_responses = @service_request.service_responses
  end

  def new
    @service_response = ServiceResponse.new
  end

  def create
    @service_request = ServiceRequest.find(params[:service_request_id])
    @service_response = @service_request.service_responses.build(service_response_params)
    @service_response.contractor_id = current_user.id # Adjust based on your logic
    #@service_request.start # start the in_progress for this response

    if @service_response.save
      # TODO: Send notification
      redirect_to service_request_service_responses_path(@service_request), notice: 'Service response was successfully created.'
    else
      # Render the respond view again with errors
      redirect_to respond_service_request_path(@service_request)
    end
  end

  private

  def authorize_user
    service_response = ServiceResponse
    authorize service_response
  end

  def service_response_params
    params.require(:service_response).permit(:message, :proposed_cost, :estimated_completion_date, :status, :service_request_id)
  end
end

class BidsController < ApplicationController
  before_action :set_bid, only: [:accept, :update, :reject, :confirm_acceptance]
  # GET /service_requests/:service_request_id/bids/new
  def new
    @service_request = ServiceRequest.find(params[:service_request_id])
    @bid = Bid.new
  end
  def create
    BidService.perform_async(:create, nil, bid_params, current_user.id)
    redirect_to service_request_path(params[:service_request_id]), notice: 'Bid creation queued for processing.'
  end

  def update
    BidService.perform_async(:update, params[:id], bid_params, current_user.id)
    redirect_to @bid.service_request, notice: 'Bid update queued for processing.'
  end

  def confirm_acceptance
    BidService.perform_async(:confirm_acceptance, params[:id], nil, current_user.id)
    redirect_to @bid.service_request, notice: 'Bid acceptance confirmation queued for processing.'
  end

  # Define the accept action
  # POST /bids/:id/accept
  def accept
    BidService.perform_async(:accept_bid, @bid.id, nil, current_user.id)
    redirect_to @bid.service_request, notice: 'Bid acceptance is being processed.'
  end

  # POST /bids/:id/reject
  def reject
    BidService.perform_async(:reject_bid, @bid.id, nil, current_user.id)
    redirect_to @bid.service_request, notice: 'Bid rejection is being processed.'
  end

  private

  def bid_params
    params.require(:bid).permit(:service_request_id, :proposed_price, :message, :estimated_timeline_in_days, :communication_preferences)
  end

  def set_bid
    @bid = Bid.find(params[:id])
  end
end
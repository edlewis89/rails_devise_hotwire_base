class BidsController < ApplicationController

  before_action :set_bid, only: [:accept, :reject]
  def new
    @bid = Bid.new
    @service_request = ServiceRequest.find(params[:service_request_id])
  end

  def create
    @bid = Bid.new(bid_params)
    @service_request = ServiceRequest.find_by(id: params[:service_request_id])

    if @service_request
      @bid.service_request = @service_request
      @bid.contractor = current_user
      if @bid.save
        redirect_to @service_request, notice: 'Bid was successfully created.'
      else
        redirect_to bid_service_request_path(@service_request), alert: 'Failed to create bid.'
      end
    else
      redirect_to root_path, alert: 'Service request not found.'
    end
  end


  # POST /bids/:id/accept
  # POST /bids/:id/accept
  def accept
    begin
      if @bid.accept!
        redirect_to @bid.service_request, notice: 'Bid was successfully accepted.'
      else
        redirect_to @bid.service_request, alert: 'Failed to accept bid.'
      end
    rescue AASM::InvalidTransition => e
      redirect_to @bid.service_request, alert: "Failed to accept bid: #{e.message}"
    end
  end

  # POST /bids/:id/reject
  def reject
    begin
      if @bid.reject!
        redirect_to @bid.service_request, notice: 'Bid was successfully rejected.'
      else
        redirect_to @bid.service_request, alert: 'Failed to reject bid.'
      end
    rescue AASM::InvalidTransition => e
      redirect_to @bid.service_request, alert: "Failed to reject bid: #{e.message}"
    end
  end

  def confirm_acceptance
    @bid = Bid.find(params[:id])
    if current_user == @bid.contractor && @bid.accepted? && @bid.service_request.open?
      begin
        @bid.confirm!
        @bid.service_request.in_progress!
        redirect_to @bid.service_request, notice: 'Bid acceptance confirmed.'
      rescue AASM::InvalidTransition
        redirect_to @bid.service_request, alert: 'Failed to confirm bid acceptance.'
      end
    else
      redirect_to root_path, alert: 'You are not authorized to perform this action.'
    end
  end

  # def confirmation
  #   # You may want to load the bid that was just created to display its details
  #   @bid = Bid.find(params[:id])
  #
  #   # You can also perform additional logic here if needed
  #
  #   # Render the confirmation page
  #   # If you have a separate view for the confirmation page, you can render it directly
  #   # For example:
  #   # render 'bids/confirmation'
  #
  #   # If you want to render a generic confirmation page, you can omit this line
  #   # and Rails will automatically render the 'confirmation.html.erb' template
  #   redirect_to service_requests_path
  # end

  private

  def bid_params
    params.require(:bid).permit(:service_request_id, :proposed_price, :message, :estimated_timeline_in_days, :communication_preferences)
  end

  def set_bid
    @bid = Bid.find(params[:id])
  end
end


# class BidsController < ApplicationController
#   before_action :set_service_request
#
#   def index
#     @bids = @service_request.bids
#   end
#
#   def new
#     @bid = @service_request.bids.build
#   end
#
#   def create
#     @bid = @service_request.bids.build(bid_params)
#
#     if @bid.save
#       broadcast_create(@bid)
#     else
#       render :new
#     end
#   end
#
#   def edit
#     @bid = Bid.find(params[:id])
#   end
#
#   def update
#     @bid = Bid.find(params[:id])
#
#     if @bid.update(bid_params)
#       broadcast_update(@bid)
#     else
#       render :edit
#     end
#   end
#
#   def destroy
#     @bid = Bid.find(params[:id])
#     @bid.destroy
#     broadcast_destroy(@bid)
#   end
#
#   private
#
#   def set_service_request
#     @service_request = ServiceRequest.find(params[:service_request_id])
#   end
#
#   def bid_params
#     params.require(:bid).permit(:amount)
#   end
#
#   def broadcast_create(bid)
#     @bids = @service_request.bids
#     respond_to do |format|
#       format.turbo_stream do
#         render turbo_stream: turbo_stream.append("bids", partial: "bids/bid", locals: { bid: bid })
#       end
#     end
#   end
#
#   def broadcast_update(bid)
#     @bids = @service_request.bids
#     respond_to do |format|
#       format.turbo_stream do
#         render turbo_stream: turbo_stream.replace("bid_#{bid.id}", partial: "bids/bid", locals: { bid: bid })
#       end
#     end
#   end
#
#   def broadcast_destroy(bid)
#     @bids = @service_request.bids
#     respond_to do |format|
#       format.turbo_stream do
#         render turbo_stream: turbo_stream.remove("bid_#{bid.id}")
#       end
#     end
#   end
# end
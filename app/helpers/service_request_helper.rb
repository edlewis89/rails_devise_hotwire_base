module ServiceRequestsHelper
  def accepted_bid_for(service_request, user)
    service_request.bids.find_by(contractor: user, status: :approved)
  end
end
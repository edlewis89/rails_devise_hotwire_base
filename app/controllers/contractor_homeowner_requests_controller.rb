# app/controllers/contractor_homeowner_requests_controller.rb
class ContractorHomeownerRequestsController < ApplicationController
  def index
    @contractor = Contractor.find(params[:contractor_id])
    @homeowner_requests = @contractor.homeowner_requests
  end

  def accept
    @contractor_homeowner_request = ContractorHomeownerRequest.find(params[:id])
    @contractor_homeowner_request.update(status: 'accepted')
    redirect_to contractor_homeowner_requests_path(current_contractor), notice: 'Request accepted.'
  end

  def decline
    @contractor_homeowner_request = ContractorHomeownerRequest.find(params[:id])
    @contractor_homeowner_request.update(status: 'declined')
    redirect_to contractor_homeowner_requests_path(current_contractor), notice: 'Request declined.'
  end
end
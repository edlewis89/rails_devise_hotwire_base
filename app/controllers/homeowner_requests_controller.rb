# app/controllers/homeowner_requests_controller.rb
class HomeownerRequestsController < ApplicationController
  def new
    @homeowner = Homeowner.find(params[:homeowner_id])
    @homeowner_request = @homeowner.homeowner_requests.build
  end
  def create
    @homeowner = Homeowner.find(params[:homeowner_id])
    @request = @homeowner.homeowner_requests.build(request_params)
    if @request.save
      redirect_to @homeowner, notice: 'Request created successfully.'
    else
      render :new
    end
  end

  private

  def request_params
    params.require(:homeowner_request).permit(:description)
  end
end
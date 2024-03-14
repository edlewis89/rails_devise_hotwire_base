# app/controllers/dashboard_controller.rb
class DashboardController < ApplicationController
  def index
    @login_count = RedisService.get_active_users_count
    @service_request_count = RedisService.get_service_request_count
    @service_response_count = RedisService.get_service_response_count
    @homeowner_count = RedisService.get_homeowner_count
    @contractor_count = RedisService.get_contractor_count
    @licensed_contractor_count = RedisService.get_licensed_contractor_count
    @unlicensed_contractor_count = RedisService.get_unlicensed_contractor_count
    # Add more analytics data as needed
  end
end

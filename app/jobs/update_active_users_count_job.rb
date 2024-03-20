# Application Job (to update active users count periodically)
class UpdateActiveUsersCountJob < ApplicationJob
  def perform
    RedisService.update_active_users_count
  end
end
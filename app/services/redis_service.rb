require 'sidekiq'
class RedisService
  include Sidekiq::Worker

  def perform
    self.class.update_analytics
  end
  def self.update_analytics
    set_service_request_count(ServiceRequest.count)
    set_bid_count(Bid.count)
    update_service_requests_with_all_bids
    update_active_users_count
    set_contractor_count(Contractor.count)
    set_homeowner_count(Homeowner.count)
    set_licensed_contractor_count(User.licensed_contractors.count)
    set_unlicensed_contractor_count(User.unlicensed_contractors.count)
  end

  def self.decrement_active_users_count
    redis.decr('active_users_count')
  end

  def self.increment_active_users_count
    redis.incr('active_users_count')
  end

  def self.get_active_users_count
    redis.get('active_users_count').to_i
  end

  def self.set_service_request_count(count)
    redis.set('service_request_count', count)
  end

  def self.get_service_request_count
    redis.get('service_request_count').to_i
  end

  def self.set_bid_count(count)
    redis.set('bid_count', count)
  end

  def self.get_bid_count
    redis.get('bid_count').to_i
  end

  def self.set_contractor_count(count)
    redis.set('contractor_count', count)
  end

  def self.get_contractor_count
    redis.get('contractor_count').to_i
  end

  def self.set_homeowner_count(count)
    redis.set('homeowner_count', count)
  end

  def self.get_homeowner_count
    redis.get('homeowner_count')
  end

  def self.set_licensed_contractor_count(count)
    redis.set('licensed_contractor_count', count)
  end

  def self.get_licensed_contractor_count
    redis.get('licensed_contractor_count').to_i
  end

  def self.set_unlicensed_contractor_count(count)
    redis.set('unlicensed_contractor_count', count)
  end

  def self.get_unlicensed_contractor_count
    redis.get('unlicensed_contractor_count').to_i
  end

  def self.update_service_requests_with_all_bids
    ServiceRequest.includes(:bids).find_each do |service_request|
      bids = service_request&.bids.pluck(:id) || [] # Assign an empty array if bids is nil
      bids_str = bids.join(',')
      set_bids_for_service_request(service_request.id, bids_str)
    end
  end

  def self.set_bids_for_service_request(service_request_id, bids)
    redis.hset('service_request_bids', service_request_id, bids)
  end

  def self.get_bids_for_service_request(service_request_id)
    redis.hget('service_request_bids', service_request_id).split(',').map(&:to_i)
  end

  def self.update_active_users_count
    active_users = User.where("last_seen_at > ?", 15.minutes.ago)
    $redis.set("active_users_count", active_users.count)
  end

  def self.get_active_users_count
    redis.get('active_users_count').to_i
  end

  private

  def self.redis
    $redis
  end
end
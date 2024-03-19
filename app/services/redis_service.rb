class RedisService
  def self.update_analytics
    set_service_request_count(ServiceRequest.count)
    set_service_response_count(Bid.count)
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

  def self.set_service_response_count(count)
    redis.set('service_response_count', count)
  end

  def self.get_service_response_count
    redis.get('service_response_count').to_i
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

  private

  def self.redis
    $redis
  end
end
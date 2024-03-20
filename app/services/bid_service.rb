class BidService
  include Sidekiq::Worker

  attr_reader :bid, :user

  def perform(action, bid_id, params, user_id)
    @bid = bid_id ? Bid.find(bid_id) : Bid.new
    @user = user_id ? User.find(user_id) : nil

    params_hash = params.present? ? eval(params) : { }
    puts " >>>>>>>> Sidekiq::Perform params_hash #{action.to_sym} #{bid_id}, #{params_hash}, #{user_id}"
    case action.to_sym
    when :create
      create_bid(@bid, params_hash, @user)
    when :update
      update_bid(@bid, params_hash)
    when :accept_bid
      accept_bid(@bid)
    when :reject_bid
      reject_bid(@bid)
    when :confirm_acceptance
      confirm_acceptance(@bid, @user)
    else
      raise ArgumentError, "Unknown action: #{action}"
    end
  rescue ActiveRecord::RecordNotFound => e
    # Handle the case when bid_id is invalid
    Rails.logger.error "Bid not found: #{e.message}"
  end

  private

  def create_bid(bid, params, user)
    bid.assign_attributes(params)
    bid.contractor = user
    bid.save
  end

  def update_bid(bid, params)
    bid.update(params)
  end

  def accept_bid(bid)
    return false unless bid.pending?

    ActiveRecord::Base.transaction do
      if bid.accept!
        return true
      else
        raise ActiveRecord::Rollback
      end
    end

    false
  end

  def reject_bid(bid)
    return false unless bid.pending?

    ActiveRecord::Base.transaction do
      if bid.reject!
        return true
      else
        raise ActiveRecord::Rollback
      end
    end

    false
  end

  def confirm_acceptance(bid, user)
    if bid.contractor == user && bid.accepted? && bid.service_request.open?
      bid.confirm!
      bid.service_request.in_progress!
    else
      raise "Invalid action"
    end
  end
end
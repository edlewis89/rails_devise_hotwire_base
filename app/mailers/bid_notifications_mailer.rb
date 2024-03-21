class BidNotificationsMailer < ApplicationMailer
  def bid_accepted_notification(bid)
    @bid = bid
    @service_request = bid.service_request
    mail(to: @bid.contractor.email, subject: 'Your Bid has been Accepted') do |format|
      format.html { render 'bid_accepted_notification' }
    end
  end
end

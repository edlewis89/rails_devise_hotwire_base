# app/workers/notification_worker.rb
require 'sidekiq'

class NotificationWorker
  include Sidekiq::Worker

  def perform(bid_id, recipient_id, sender_id, message, notification_type)
    recipient = User.find_by(id: recipient_id)
    sender = User.find_by(id: sender_id)
    puts ">>>>>>>>>>>> NotificationWorker:: Worker bid id: #{bid_id} recipient #{recipient.email} sender #{sender.email} message #{message} notify type: #{notification_type}"
    case notification_type.to_sym
    when :bid_accepted
      bid = Bid.find(bid_id.to_i)
      if bid.present?
        BidNotificationsMailer.bid_accepted_notification(bid).deliver_now
        # Create a new notification record in the database
        # Find an existing notification for the given service request
        notification = Notification.find_or_initialize_by(
          recipient: recipient,
          sender: sender,
          message: message,
          notification_type: notification_type
        )

        # Save the notification if it's new
        if notification.new_record?
          notification.save!
          Rails.logger.info("New notification created: recipient_id=#{recipient_id}, sender_id=#{sender_id}, message=#{message}, notification_type=#{notification_type}")
        else
          Rails.logger.info("Notification already exists for recipient_id=#{recipient_id}, sender_id=#{sender_id}, message=#{message}, notification_type=#{notification_type}")
        end
      else
        Rails.logger.error "Bid not found for Bid id: #{bid_id}"
      end
    else
      Rails.logger.error "Unhandled notification type: #{notification_type}"
    end
  end
end

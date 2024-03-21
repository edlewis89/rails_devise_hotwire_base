# app/models/notification.rb
class Notification < ApplicationRecord
  belongs_to :recipient, class_name: 'User'
  belongs_to :sender, class_name: 'User', optional: true

  enum notification_type: %i(bid_accepted)

  # Additional methods as needed
end
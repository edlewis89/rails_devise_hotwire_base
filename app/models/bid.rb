class Bid < ApplicationRecord
  belongs_to :service_request
  belongs_to :contractor, class_name: 'User'

  validates :proposed_price, presence: true, numericality: { greater_than: 0 }
  validates :message, :estimated_timeline_in_days, presence: true

  after_update :create_notification, if: :accepted?

  scope :accepted, -> { where(status: :accepted) }

  enum status: %i(pending accepted confirmed rejected)

  include AASM

  aasm column: 'status' do
    state :pending, initial: true
    state :accepted
    state :confirmed
    state :rejected

    event :accept do
      transitions from: :pending, to: :accepted
    end

    event :confirm do
      transitions from: :accepted, to: :confirmed
    end

    event :reject do
      transitions from: [:pending, :accepted], to: :rejected
    end
  end

  def human_readable_status
    status.to_s.titleize
  end

  def force_notification
    create_notification
  end

  private

  def no_accepted_bid_exists?
    return true unless service_request.present?

    !service_request.bids.accepted.exists?
  end

  def notification_message
    "Your bid for <a href='#{Rails.application.routes.url_helpers.service_request_url(service_request)}'>#{service_request.title}</a> has been accepted."
  end

  def create_notification
    # Determine recipient and sender IDs
    recipient_id = contractor.id
    sender_id = service_request.homeowner.id

    # Enqueue a job to send the notification asynchronously
    NotificationWorker.perform_async(self.id, recipient_id, sender_id, notification_message, :bid_accepted)
  end
end
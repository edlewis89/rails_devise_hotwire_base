class Bid < ApplicationRecord
  belongs_to :service_request
  belongs_to :contractor

  validates :proposed_price, presence: true, numericality: { greater_than: 0 }
  validates :message, :estimated_timeline_in_days, presence: true

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

  private

  def no_accepted_bid_exists?
    return true unless service_request.present?

    !service_request.bids.accepted.exists?
  end

end
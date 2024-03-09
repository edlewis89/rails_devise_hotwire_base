class ServiceResponse < ApplicationRecord
  belongs_to :contractor
  belongs_to :service_request

  include AASM

  # Define AASM states
  aasm column: 'status' do
    state :pending, initial: true
    state :accepted
    state :rejected

    # Define AASM transitions
    event :accept do
      transitions from: :pending, to: :accepted
    end

    event :reject do
      transitions from: :pending, to: :rejected
    end
  end

  # Scope to return all contractor responses
  scope :contractor_responses, -> { joins(:contractor) }
  # Scope to return all responses for a given service request
  scope :for_service_request, ->(service_request_id) { where(service_request_id: service_request_id) }

end
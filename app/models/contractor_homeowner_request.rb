# app/models/contractor_homeowner_request.rb
class ContractorHomeownerRequest < ApplicationRecord
  belongs_to :user
  #belongs_to :contractor, class_name: 'User', foreign_key: 'contractor_id' # Assuming User represents both homeowners and contractors
  belongs_to :homeowner_request


  # The types of status you might need for ContractorHomeownerRequest could include:
  #
  #   Pending: The request has been created but not yet accepted or declined by the contractor.
  #   Accepted: The contractor has accepted the request.
  #   Declined: The contractor has declined the request.
  #   Completed: The work associated with the request has been completed.
  #   Cancelled: The request has been cancelled by either the homeowner or the contractor.
  #
  include AASM

  enum status: {
    pending: 0,
    accepted: 1,
    declined: 2,
    completed: 3,
    cancelled: 4
  }

  aasm column: 'status', enum: true do
    state :pending, initial: true
    state :accepted
    state :declined
    state :completed
    state :cancelled

    event :accept do
      transitions from: :pending, to: :accepted
    end

    event :decline do
      transitions from: :pending, to: :declined
    end

    event :complete do
      transitions from: [:accepted, :pending], to: :completed
    end

    event :cancel do
      transitions from: [:accepted, :pending], to: :cancelled
    end
  end
end
class ServiceRequest < ApplicationRecord
  belongs_to :homeowner
  belongs_to :service
  has_many :service_responses, dependent: :destroy

  attr_accessor :image, :remote_image_url
  mount_uploader :image, ImageUploader

  delegate :type, to: :user, prefix: true, allow_nil: false

  validates :description, :service, :location, :budget, :timeline, presence: true

  include AASM

  # Define AASM states
  aasm column: 'status' do
    state :pending, initial: true
    state :in_progress
    state :completed
    state :cancelled

    # Define AASM transitions
    event :start do
      transitions from: :pending, to: :in_progress
    end

    event :complete do
      transitions from: :in_progress, to: :completed
    end

    event :cancel do
      transitions from: %i[pending in_progress], to: :cancelled
    end
  end

  scope :for_service_request, ->(service_request_id) { where(service_request_id: service_request_id) }
  # Scope to return all responses for a given contractor
  scope :for_contractor, ->(contractor_id) { joins(:service_responses).where(service_responses: { contractor_id: contractor_id }) }

  private
end
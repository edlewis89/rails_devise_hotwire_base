class ServiceRequest < ApplicationRecord
  belongs_to :homeowner, class_name: "User"
  has_and_belongs_to_many :services

  has_many :service_responses, dependent: :destroy

  has_many_attached :images
  has_many :bids

  has_one :profile, through: :homeowner
  has_many :addresses, through: :profile

  # Assuming the address model has latitude and longitude attributes
  delegate :latitude, :longitude, to: :addresses

  scope :for_service_request, ->(service_request_id) { where(service_request_id: service_request_id) }
  # Scope to return all responses for a given contractor
  scope :responses_by_contractor, ->(contractor_id) { joins(:service_responses).where(service_responses: { contractor_id: contractor_id }) }

  validates :title, :description, :location, :budget, :timeline, presence: true

  enum status: %i(pending open in_progress completed cancelled closed)

  # In this updated AASM state machine for ServiceRequest, I've added a new state called open to indicate that the service request is open for accepting bids. Here's what each state represents:
  #
  #                                                                                                                                                                                     pending: The initial state when the service request is created but not yet open for bidding.
  #   open: Indicates that the service request is open for accepting bids from service providers.
  #   in_progress: Represents that the service request is currently being fulfilled or work is in progress.
  #   completed: Indicates that the service request has been successfully completed.
  #   cancelled: Signifies that the service request has been cancelled, either before or during its execution.
  #   closed: Marks the closure of the service request, which can happen after it has been completed or cancelled.
  #
  #

  include AASM

  # Define AASM states
  aasm column: 'status' do
    state :pending, initial: true
    state :open
    state :in_progress
    state :completed
    state :cancelled
    state :closed

    # Define AASM transitions
    event :start do
      transitions from: [:pending, :open], to: :in_progress
    end

    event :complete do
      transitions from: :in_progress, to: :completed
    end

    event :cancel do
      transitions from: [:pending, :open, :in_progress], to: :cancelled
    end

    event :close do
      transitions from: [:completed, :cancelled], to: :closed
    end
  end

  def match_contractors
    Contractor.match_with_service_request(self)
  end

  def editable_by?(current_user)
    current_user.service_provider? && (current_user.pro? || current_user.premium?)
  end

  def destroyable_by?(current_user)
    current_user.property_owner?
  end

  def human_readable_status
    status.to_s.titleize
  end

  # Check if a contractor's bid has been accepted for this service request
  def contractor_bid_accepted?(contractor_id)
    bids.accepted.exists?(contractor_id: contractor_id)
  end

  def accepted_bid_for(service_request, user)
    service_request.bids.find_by(contractor: user, status: :approved)
  end

  def has_accepted_bids_for_user?(user)
    accepted_bids.exists?(contractor: user)
  end

  # Method to check if there are any confirmed bids for a given user
  def has_confirmed_bids_for_user?(user)
    confirmed_bids.exists?(contractor: user)
  end

  # Method to filter service requests within a contractor's zipcode radius
  # def self.within_contractor_zipcode_radius(contractor)
  #   contractor_address = contractor.profile.addresses.last
  #   return [] unless contractor_address.present? && contractor_address.latitude.present? && contractor_address.longitude.present?
  #
  #   within_radius = []
  #   ServiceRequest.all.each do |request|
  #     request.addresses.each do |address|
  #       next unless address.latitude.present? && address.longitude.present?
  #
  #       distance = Geocoder::Calculations.distance_between(
  #         [contractor_address.latitude, contractor_address.longitude],
  #         [address.latitude, address.longitude],
  #         units: :mi
  #       )
  #       within_radius << request if distance <= request.zipcode_radius
  #     end
  #   end
  #   within_radius
  # end
  def eligible_contractors
    homeowner_address = homeowner.profile.addresses.last
    return [] unless homeowner_address.present?

    # Convert zipcode_radius from miles to kilometers
    # zipcode_radius_km = zipcode_radius * Geocoder::Calculations::MI_IN_KM

    # Do not convert.  Keep it in miles.
    zipcode_radius_km = zipcode_radius # * Geocoder::Calculations::MI_IN_KM

    # Find all contractors within the specified radius of the homeowner's address
    Contractor.joins(profile: :addresses)
              .where("ST_DWithin(ST_MakePoint(addresses.longitude, addresses.latitude)::geography,
                    ST_MakePoint(?, ?)::geography,
                    ?)", homeowner_address.longitude, homeowner_address.latitude, zipcode_radius_km)
  end


  def self.for_contractor(contractor)
    return [] unless contractor.profile.addresses.present?

    contractor_address = contractor.profile.addresses.last

    # No conversion needed.  Keep it in miles.
    zipcode_radius_km = contractor.zipcode_radius # * Geocoder::Calculations::MI_IN_KM

    ServiceRequest.joins(homeowner: { profile: :addresses })
                  .where("ST_DWithin(ST_MakePoint(addresses.longitude, addresses.latitude)::geography,
                                     ST_MakePoint(?, ?)::geography,
                                     ?)", contractor_address.longitude, contractor_address.latitude, zipcode_radius_km)
  end


  private

  # Helper method to fetch accepted bids
  def accepted_bids
    bids.accepted
  end

  # Helper method to fetch confirmed bids
  def confirmed_bids
    bids.confirmed
  end
end
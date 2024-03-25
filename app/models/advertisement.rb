class Advertisement < ApplicationRecord
  belongs_to :service
  has_many :addresses, as: :addressable, dependent: :destroy

  accepts_nested_attributes_for :addresses

  delegate :city, :state, :zipcode, to: :primary_address, prefix: true, allow_nil: true

  enum advertisement_type: { regular: 0, featured: 1 }
  enum placement: { top: 0, middle: 1, bottom: 2, left: 3, right: 4 }

  # If you want to allow remote image URLs for uploading
  attr_accessor :remote_image_url
  mount_uploader :image_data, ImageUploader

  def self.advertisement_type_values
    advertisement_types.keys.map { |key| [key.titleize, key] }
  end

  def self.placement_values
    placements.keys.map { |key| [key.titleize, key] }
  end


  private

  def primary_address
    addresses.first
  end
end

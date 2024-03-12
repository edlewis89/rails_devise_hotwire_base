class Advertisement < ApplicationRecord
  belongs_to :service
  has_many :addresses, as: :addressable, dependent: :destroy

  accepts_nested_attributes_for :addresses

  delegate :city, :state, :zipcode, to: :primary_address, prefix: true, allow_nil: true

  # If you want to allow remote image URLs for uploading
  attr_accessor :remote_image_url

  mount_uploader :image_data, ImageUploader

  private

  def primary_address
    addresses.first
  end
end

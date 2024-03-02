class ServiceRequest < ApplicationRecord
  belongs_to :user, polymorphic: true
  belongs_to :type_of_work

  attr_accessor :image, :remote_image_url

  mount_uploader :image, ImageUploader

  delegate :type, to: :user, prefix: true, allow_nil: false

  validates :description, :type_of_work, :location, :budget, :timeline, presence: true

  private
end
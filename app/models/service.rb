class Service < ApplicationRecord
  has_many :contractor_services
  has_many :contractors, through: :contractor_services

  has_and_belongs_to_many :service_requests
  has_many :advertisements
end
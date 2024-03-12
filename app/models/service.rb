class Service < ApplicationRecord
  has_many :service_requests
  has_many :advertisements
end
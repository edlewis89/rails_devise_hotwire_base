class HomeownerRequest < ApplicationRecord
  has_many :contractor_homeowner_requests
  has_many :contractors, through: :contractor_homeowner_requests

  belongs_to :user #STI
end

#belongs_to :homeowner, class_name: 'User', foreign_key: 'homeowner_id' # Assuming User represents both homeowners and contractors


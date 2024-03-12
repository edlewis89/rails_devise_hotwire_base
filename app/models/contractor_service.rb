class ContractorService < ApplicationRecord
  belongs_to :contractor
  belongs_to :service
end
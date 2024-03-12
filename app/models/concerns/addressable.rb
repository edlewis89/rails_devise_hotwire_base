class Addressable < ApplicationRecord
  has_many :advertisementss, as: :addressable
end
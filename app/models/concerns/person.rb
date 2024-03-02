module Person
  extend ActiveSupport::Concern

  included do
    # Common attributes and methods here
    validates :name, presence: true
    validates :email, presence: true
    validates :phone_number, presence: true
    # Add more shared validations or methods as needed
  end
end
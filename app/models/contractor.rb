class Contractor < ApplicationRecord

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone_number, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :zipcode, presence: true
  validates :website, allow_blank: true, format: { with: URI.regexp }, if: -> { website.present? }
  validates :service_area, presence: true
  validates :years_of_experience, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :hourly_rate, numericality: { greater_than_or_equal_to: 0 }
  validates :license_number, presence: true, if: Proc.new { |contractor| contractor.license_number.present? }
  validate :unique_license_number?, if: -> { license_number.present? }

  validates_presence_of :insurance_provider, :insurance_policy_number, if: :require_insurance?

  private

  def require_insurance?
    have_insurance?  # Validate insurance attributes if have_insurance is true
  end

  def unique_license_number?
    existing_contractor = self.class.find_by(license_number:)
    return unless existing_contractor && existing_contractor != self

    errors.add(:license_number, 'has already been taken')
  end
end

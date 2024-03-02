class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :homeowner_requests
  has_many :contractor_homeowner_requests, through: :homeowner_requests

  has_one :profile, as: :profileable

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  #after_create :ensure_profile_exists

  enum role: %i(general homeowner contractor admin)

  # Define a scope for active records
  scope :active_records, -> { where(active: true) }

  # Define a scope for public records
  scope :public_records, -> { where(public: true) }

  def c
    active
  end

  def is_public?
    public
  end

  private
end

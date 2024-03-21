class User < ApplicationRecord
  self.inheritance_column = :type
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  # :general: General users
  # :property_owner: Property owners
  # :service_provider: Service providers (contractors)
  # :admin: Administrators
  #
  enum role: %i(general property_owner service_provider ad_manager admin)
  enum subscription_level: %i(basic premium pro)

  # Conversations initiated by the user as the sender
  has_many :sent_conversations, foreign_key: :sender_id, class_name: 'Conversation', dependent: :destroy
  # Conversations initiated by the user as the recipient
  has_many :received_conversations, foreign_key: :recipient_id, class_name: 'Conversation', dependent: :destroy
  # Messages sent by the user
  has_many :messages, dependent: :destroy

  has_many :notifications, foreign_key: :recipient_id

  has_one :profile, foreign_key: 'user_id', dependent: :destroy


  # Define a scope for active records
  scope :active_users, -> { where(active: true) }
  # Define a scope for public users
  scope :public_users, -> { where(public: true) }
  scope :by_type, ->(user_type) { where(type: user_type) }
  scope :by_role, ->(user_role) { where(type: user_role) }

  # Assuming you have a 'role' attribute in your User model to differentiate between users and contractors
  scope :contractors, -> { where(role: 'service_provider') }
  scope :licensed_contractors, -> { contractors.joins(:profile).where(profiles: { have_license: true }) }
  # Scope to fetch unlicensed contractors
  scope :unlicensed_contractors, -> { contractors.where.not(id: licensed_contractors) }

  # Scope to fetch profile by user id and profileable_type
  # # Example usage
  # contractor_user = User.with_profile_by_type(contractor.id, 'Contractor').first
  scope :with_profile_by_type, ->(user_id, profileable_type) do
    joins(:profile).where(profiles: { profileable_id: user_id, profileable_type: profileable_type })
  end

  scope :homeowners, -> { where(type: 'Homeowner') }
  scope :contractors, -> { where(type: 'Contractor') }

  delegate :name, to: :profile, prefix: true, allow_nil: true
  delegate :have_license, to: :profile, allow_nil: true, prefix: false
  delegate :zipcode, to: :primary_address, prefix: true, allow_nil: true
  delegate :city, to: :primary_address, prefix: true, allow_nil: true

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  accepts_nested_attributes_for :profile
  #after_create :create_user_profile  #unable to do this cause name and phonenumber are validated to be present

  def is_active?
    active
  end

  def is_public?
    public
  end

  def has_license?
    # Check if the user has a profile and if the profile has the have_license attribute set to true
    if profile&.have_license == true
      profile.license_number
    else
      false
    end
  end

  def profile
    profile ||= Profile.find_or_initialize_by(user_id: id)
  end

  private

  def create_user_profile
    # Create a profile for the user if it doesn't exist
    self.create_profile unless self.profile
  end

  def primary_address
    profile&.addresses&.first
  end
end

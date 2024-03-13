class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  # has_many :sent_messages, as: :sender, class_name: 'Message'
  # has_many :received_messages, as: :recipient, class_name: 'Message'
  #has_many :sent_messages, class_name: "Message", foreign_key: "sender_id"
  #has_many :received_messages, class_name: "Message", foreign_key: "recipient_id"

  # :general: General users
  # :property_owner: Property owners
  # :service_provider: Service providers (contractors)
  # :admin: Administrators
  #
  enum role: %i(general property_owner service_provider ad_manager admin)
  enum subscription_level: %i(basic premium pro)

  has_many :homeowner_requests
  has_many :contractor_homeowner_requests, through: :homeowner_requests
  # Conversations initiated by the user as the sender
  has_many :sent_conversations, foreign_key: :sender_id, class_name: 'Conversation', dependent: :destroy
  # Conversations initiated by the user as the recipient
  has_many :received_conversations, foreign_key: :recipient_id, class_name: 'Conversation', dependent: :destroy
  # Messages sent by the user
  has_many :messages, dependent: :destroy
  has_one :profile, as: :profileable, dependent: :destroy

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  
  accepts_nested_attributes_for :profile

  delegate :name, to: :profile, prefix: true, allow_nil: true
  delegate :primary_address_zipcode, to: :profile, prefix: false, allow_nil: true
  delegate :primary_address_city, to: :profile, prefix: false, allow_nil: true

  # Define a scope for active records
  scope :active_users, -> { where(active: true) }
  # Define a scope for public users
  scope :public_users, -> { where(public: true) }
  scope :by_type, ->(user_type) { where(type: user_type) }
  scope :by_role, ->(user_role) { where(type: user_role) }

  # Scope to fetch profile by user id and profileable_type
  # # Example usage
  # contractor_user = User.with_profile_by_type(contractor.id, 'Contractor').first
  scope :with_profile_by_type, ->(user_id, profileable_type) do
    joins(:profile).where(profiles: { profileable_id: user_id, profileable_type: profileable_type })
  end

  #after_create :create_user_profile  #unable to do this cause name and phonenumber are validated to be present

  def is_active?
    active
  end

  def is_public?
    public
  end

  private


  def create_user_profile
    # Create a profile for the user if it doesn't exist
    self.create_profile unless self.profile
  end
end

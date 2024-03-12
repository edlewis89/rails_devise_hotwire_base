class Profile < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  belongs_to :user
  belongs_to :profileable, polymorphic: true
  has_many :addresses, as: :addressable

  accepts_nested_attributes_for :addresses

  # Validations, attr_accessors, and other model code...
  validates :name, presence: true
  validates :phone_number, presence: true
  validates :availability, inclusion: { in: [true, false] }
  validates :website, allow_blank: true, format: { with: URI.regexp }, if: -> { website.present? }
  validates :years_of_experience, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :hourly_rate, numericality: { greater_than_or_equal_to: 0 }
  validates :license_number, presence: true, if: Proc.new { |contractor| contractor.license_number.present? }
  validate :unique_license_number?, if: -> { license_number.present? }

  validates_presence_of :insurance_provider, :insurance_policy_number, if: :require_insurance?

  # If you want to allow remote image URLs for uploading
  attr_accessor :remote_image_url

  mount_uploader :image_data, ImageUploader

  delegate :role, :type, :active, :public, :email, to: :user, prefix: true, allow_nil: true
  delegate :city, :state, :zipcode, to: :primary_address, prefix: true, allow_nil: true

  after_create :validate_service_area_for_service_provider

  scope :active_profiles, -> { joins(:user).where(users: { active: true }) }
  scope :active_and_public_profiles, -> { joins(:user).where(users: { active: true, public: true }) }
  scope :contractor_profiles, -> { where(profileable_type: 'Contractor') }
  scope :homeowner_profiles, -> { where(profileable_type: 'Homeowner') }
  scope :admin_profiles, -> { where(profileable_type: 'Admin') }
  scope :ad_manager_profiles, -> { where(profileable_type: 'AdManager') }

  ## Example usage
  # contractor_profiles = Profile.by_profileable(contractor.id, 'Contractor')
  scope :by_profileable, ->(profileable_id, profileable_type) do
    where(profileable_id: profileable_id, profileable_type: profileable_type)
  end

  before_commit on: [:create, :update] do
    ensure_index_exists unless index_exists?
  end

  after_commit on: [:create, :update] do
    ensure_index_exists unless index_exists?

    update_or_create_document
  end

  after_commit on: [:destroy] do
    #delete_document if document_exists?
  end

  settings index: { number_of_shards: 1 } do
    mappings dynamic: 'false' do
      indexes :name, type: 'text'
      indexes :email, type: 'text'
      indexes :description, type: 'text'
      indexes :phone_number, type: 'text'
      indexes :city, type: 'text'
      indexes :state, type: 'text'
      indexes :zipcode, type: 'text'
      indexes :license_number, type: 'text'
      indexes :insurance_provider, type: 'text'
      indexes :insurance_policy_number, type: 'text'
      indexes :have_license, type: 'boolean'
      indexes :have_insurance, type: 'boolean'
      indexes :service_area, type: 'text'
      indexes :years_of_experience, type: 'integer'
      indexes :specializations, type: 'text'
      indexes :certifications, type: 'text'
      indexes :languages_spoken, type: 'text'
      indexes :hourly_rate, type: 'float'
      indexes :profileable_type, type: 'text'
      indexes :user_type, type: 'text'
      indexes :availability, type: 'boolean'
      indexes :public, type: 'boolean' # Assuming photo is a URL or path
      indexes :active, type: 'boolean'
    end
  end

  def self.search_in_elastic(query)
    self.__elasticsearch__.search(query) if query.present?
  end

  def as_indexed_json(options = {})
    # as_indexed_json implementation...
    indexed_json = {
      profileable_type: profileable_type,
      user_type: user_type,
      id: id,
      email: user_email,
      name: name,
      description: description,
      phone_number: phone_number,
      city: primary_address_city,
      state: primary_address_state,
      zipcode: primary_address_zipcode,
      service_area: service_area,
      years_of_experience: years_of_experience,
      specializations: specializations,
      certifications: certifications,
      languages_spoken: languages_spoken,
      hourly_rate: hourly_rate,
      availability: availability,
      active: user_active,
      public: user_public
    }

    if profileable_type == "Contractor"
      indexed_json[:license_number] = license_number
      indexed_json[:insurance_provider] = insurance_provider
      indexed_json[:insurance_policy_number] = insurance_policy_number
      indexed_json[:have_license] = have_license
      indexed_json[:have_insurance] = have_insurance
    end

    indexed_json
  end

  # Getter method to return an array from the specializations string
  def specializations_array
    specializations.join(',') if specializations.present?
  end

  # Setter method to handle both string and array inputs for specializations
  def specializations_array=(value)
    if value.is_a?(String)
      self.specializations = value.split(',').map(&:strip).reject(&:blank?)
    end
  end

  def certifications_array
    certifications.join(',') if certifications.present?
  end

  # Setter method to handle both string and array inputs for specializations
  def certifications_array=(value)
    if value.is_a?(String)
      self.certifications = value.split(',').map(&:strip).reject(&:blank?)
    end
  end

  def languages_array
    languages_spoken.join(',') if languages_spoken.present?
  end

  # Setter method to handle both string and array inputs for specializations
  def languages_array=(value)
    if value.is_a?(String)
      self.languages_spoken = value.split(',').map(&:strip).reject(&:blank?)
    end
  end

  def require_insurance?
    have_insurance?  # Validate insurance attributes if have_insurance is true
  end

  def unique_license_number?
    existing_contractor = self.class.find_by(license_number: license_number)
    return unless existing_contractor && existing_contractor != self

    errors.add(:license_number, 'has already been taken')
  end

  private

  def validate_service_area_for_service_provider
    if user.service_provider? && service_area.blank?
      errors.add(:service_area, "can't be blank for service providers")

      raise ActiveRecord::RecordInvalid.new(self)
    end
  end

  def primary_address
    addresses.first
  end

  def update_or_create_document
    if condition_met_for_update_or_create?
      document_exists? ? __elasticsearch__.update_document : create_document_in_elasticsearch
    end
  end

  # Method to create the document in Elasticsearch
  def create_document_in_elasticsearch
    __elasticsearch__.index_document || __elasticsearch__.import
  end

  def delete_document
    __elasticsearch__.delete_document if document_exists?
  end

  def document_exists?
    ElasticsearchHelper.instance.document_exists?(index_name, self.id)
  end

  def condition_met_for_update_or_create?
    # Define your condition for updating documents
    index_exists?

    user.is_active? #&& (user.service_provider?)
  end

  def ensure_index_exists
    mappings = index_mappings

    # Now you have the mappings stored in the mappings variable
    puts mappings

    ElasticsearchHelper.instance.create_index_with_mappings!(index_name, mappings) unless index_exists?
  end

  def index_exists?
    ElasticsearchHelper.instance.index_exists?(index_name)
  end

  def self.search_elastic(query)

    # Get the mappings hash for the Profile model
    mappings = index_mappings
    puts mappings

    # Extract the properties hash from the mappings
    properties = mappings.dig(:properties)
    puts "properties #{properties}"

    # Get the keys (fields) from the properties hash
    array_of_symbols = properties&.keys

    fields = array_of_symbols&.map(&:to_s)
    # Now fields contains an array of field names from the Elasticsearch mappings
    puts ">>>>>>>> fields #{fields}"
    fields = ["name","email","description","phone_number","city","state","zipcode","license_number","insurance_provider","insurance_policy_number","have_license","have_insurance","service_area","years_of_experience","specializations","certifications","languages_spoken","hourly_rate","availability","active","public","user_type","profileable_type"]
    #fields = ["name","email","description","phone_number","city","state","zipcode","license_number","insurance_provider","insurance_policy_number","service_area","years_of_experience","specializations","certifications","languages_spoken","hourly_rate","profileable_type"]

    return ElasticsearchHelper.instance.search_if_index_exists(index_name, query, fields) if fields

    nil
  end

  def index_mappings
    Profile.mappings.to_hash
  end

  def index_name
    "profiles"
  end
end

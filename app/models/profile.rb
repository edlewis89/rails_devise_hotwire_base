class Profile < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  belongs_to :user
  belongs_to :profileable, polymorphic: true

  #belongs_to :homeowner, optional: true
  #belongs_to :contractor, optional: true
  #belongs_to :profileable, polymorphic: true

  validates :name, presence: true
  validates :phone_number, presence: true
  validates :availability, inclusion: { in: [true, false] }
  validates :city, presence: true
  validates :state, presence: true
  validates :zipcode, presence: true
  validates :service_area, presence: true
  validates :website, allow_blank: true, format: { with: URI.regexp }, if: -> { website.present? }
  validates :years_of_experience, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :hourly_rate, numericality: { greater_than_or_equal_to: 0 }
  validates :license_number, presence: true, if: Proc.new { |contractor| contractor.license_number.present? }
  validate :unique_license_number?, if: -> { license_number.present? }

  validates_presence_of :insurance_provider, :insurance_policy_number, if: :require_insurance?

  attr_accessor :image, :remote_image_url

  mount_uploader :image, ImageUploader

  delegate :active, :type, :email, :public, to: :user, prefix: true, allow_nil: true

  before_commit on: [:create, :update] do
    ensure_index_exists unless index_exists?
  end

  after_commit on: [:create] do
    ensure_index_exists unless index_exists?
    if condition_met_for_update?
      __elasticsearch__.update_document
    else
      __elasticsearch__.delete_document
    end
  end

  after_commit on: [:update] do
    ensure_index_exists unless index_exists?
    if condition_met_for_update?
      __elasticsearch__.update_document
    else
      __elasticsearch__.delete_document
    end
  end

  after_commit on: [:destroy] do
    begin
      if __elasticsearch__.record_exists?
        __elasticsearch__.delete_document
      end
    rescue => e
      Rails.logger.error("Error deleting document from Elasticsearch: #{e.message}")
    end
  end

  # Define the Elasticsearch index settings and mappings
  def self.create_index_with_mappings!
    settings_hash = {
      index: {
        number_of_shards: 1,
        # Add any other settings you need
      }
    }

    mappings_hash = {
      dynamic: 'false', # Prevent dynamic mapping
      properties: {
        name: { type: 'text' },
        email: { type: 'text', fields: { keyword: { type: 'keyword' } } },
        description: { type: 'text' },
        phone_number: { type: 'text' },
        city: { type: 'text' },
        state: { type: 'text' },
        zipcode: { type: 'text' },
        license_number: { type: 'text' },
        insurance_provider: { type: 'text' },
        insurance_policy_number: { type: 'text' },
        have_license: { type: 'boolean' },
        have_insurance: { type: 'boolean' },
        service_area: { type: 'text' },
        years_of_experience: { type: 'integer' },
        specializations: { type: 'text' },
        certifications: { type: 'text' },
        languages_spoken: { type: 'text' },
        hourly_rate: { type: 'float' },
        availability: { type: 'boolean' },
        active: { type: 'boolean' },
        public: { type: 'boolean' },
        user_type: { type: 'text', fields: { keyword: { type: 'keyword' } } },
        profileable_type: { type: 'text', fields: { keyword: { type: 'keyword' } } }
      }
    }
    # Create the Elasticsearch index with the defined settings and mappings
    __elasticsearch__.create_index!(settings: settings_hash, mappings: mappings_hash)
  end

  def self.search(query)
    #__elasticsearch__.search(params[:q], [self, Category]).results.to_a.map(&:to_hash)
    __elasticsearch__.search(query) if query.present?
  end

  def self.search_in_elasticsearch(query)
    ElasticsearchHelper.search_if_index_exists(index_name, query)
  end

  def as_indexed_json(options = {})
    indexed_json = {
      profileable_type: profileable_type,
      user_type: user_type,
      id: id,
      email: user_email,
      name: name,
      description: description,
      phone_number: phone_number,
      city: city,
      state: state,
      zipcode: zipcode,
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

  private

  def require_insurance?
    have_insurance?  # Validate insurance attributes if have_insurance is true
  end

  def unique_license_number?
    existing_contractor = self.class.find_by(license_number:)
    return unless existing_contractor && existing_contractor != self

    errors.add(:license_number, 'has already been taken')
  end

  def condition_met_for_destroy?
    condition_met? && document_exists?(index_name, self.id)
  end

  def condition_met_for_index?
    condition_met?
  end

  def condition_met_for_update?
    condition_met?
  end

  def condition_met?
    # Define your condition here
    index_exists?

    user.is_active? && user.is_public?
  end

  def index_exists?
    ElasticsearchHelper.index_exists?(index_name)
  end

  def ensure_index_exists
    # Call the method to create the index with mappings
    Profile.create_index_with_mappings!
    #ElasticsearchHelper.create_index(index_name, elasticsearch_mappings(Profile))
  end

  # def index_exists?
  #   ElasticsearchHelper.index_exists?(index_name)
  # end
  #
  # def ensure_index_exists
  #   ElasticsearchHelper.create_index(index_name, elasticsearch_mappings(self))
  # end

  def index_name
    "profiles"
  end

  # # Class method to get the Elasticsearch mappings
  # def self.elasticsearch_mappings(_klass)
  #   mappings_hash = _klass.mappings.to_hash
  #   if mappings_hash.nil?
  #     Rails.logger.error("Mappings are not defined for the #{_klass.name} model.")
  #     return {}
  #   else
  #     return mappings_hash
  #   end
  # end

  # def self.create_index_with_mappings!
  #   ElasticsearchHelper.create_index_with_mappings!(self.index_name, elasticsearch_mappings(self))
  # end

  # def self.index_exists?
  #   ElasticsearchHelper.index_exists?(self.index_name)
  # end

  # def document_exists?(index_name, document_id)
  #   binding.pry
  #   # Perform a search to check if the document exists
  #   response = __elasticsearch__.client.search(index: index_name, body: { query: { match: { _id: document_id } } })
  #
  #   # If the document exists, return true
  #   response["hits"]["total"]["value"] > 0
  # end
end

class Contractor < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

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

  attr_accessor :image, :remote_image_url

  mount_uploader :image, ImageUploader

  # Define a scope for active records
  scope :active, -> { where(active: true) }

  settings index: { number_of_shards: 1 } do
    mappings dynamic: 'false' do
      indexes :name, type: 'text'
      indexes :description, type: 'text'
      indexes :email, type: 'text'
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
      indexes :photo, type: 'text' # Assuming photo is a URL or path
      indexes :active, type: 'boolean'
    end
  end

  before_commit on: [:create, :update] do
    ensure_index_exists unless index_exists?
    #__elasticsearch__.index_document if condition_met_for_index?
  end

  after_commit on: [:create] do
    ensure_index_exists unless index_exists?
    #__elasticsearch__.index_document if condition_met_for_index?
  end

  after_commit on: [:update] do
    binding.pry
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

  # after_commit :index_document_on_create, on: :create
  # after_commit :update_document_on_update, on: :update
  # after_commit :delete_document_on_destroy, on: :destroy

  def self.search(query)
    #__elasticsearch__.search(params[:q], [self, Category]).results.to_a.map(&:to_hash)
    __elasticsearch__.search(query) if query.present?
  end

  def self.search_in_elasticsearch(query)
    ElasticsearchHelper.search_if_index_exists(index_name, query)
  end

  def as_indexed_json(options = {})
    # as_json(
    #   only: [:id, :name, :description],
    #   include: {
    #     categories: {
    #       only: [:id, :name, :description]
    #     }
    #   }
    # )
    self.as_json(
      options.merge(
        except: []#,
        #include: { categories: { only: [:id, :name, :description] } }
      )
    )
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
    binding.pry
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

    active?
  end

  def index_exists?
    ElasticsearchHelper.index_exists?(index_name)
  end

  def ensure_index_exists
    ElasticsearchHelper.create_index(index_name, elasticsearch_mappings)
  end

  def index_name
    "contractors"
  end

  # Class method to get the Elasticsearch mappings
  def self.elasticsearch_mappings(_klass)
    mappings_hash = _klass.mappings.to_hash
    if mappings_hash.nil?
      Rails.logger.error("Mappings are not defined for the #{_klass.name} model.")
      return {}
    else
      return mappings_hash
    end
  end

  def self.create_index_with_mappings!
    ElasticsearchHelper.create_index_with_mappings!(self.index_name, elasticsearch_mappings(self))
  end

  def self.index_exists?
    ElasticsearchHelper.index_exists?(self.index_name)
  end

  # def document_exists?(index_name, document_id)
  #   binding.pry
  #   # Perform a search to check if the document exists
  #   response = __elasticsearch__.client.search(index: index_name, body: { query: { match: { _id: document_id } } })
  #
  #   # If the document exists, return true
  #   response["hits"]["total"]["value"] > 0
  # end
end

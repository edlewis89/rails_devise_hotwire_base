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

  index_name 'contractors'

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

  after_commit lambda { __elasticsearch__.index_document  },  on: :create
  # after_touch  lambda { __elasticsearch__.index_document  },  on: :touch
  after_commit lambda { __elasticsearch__.update_document },  on: :update
  after_commit lambda { __elasticsearch__.delete_document },  on: :destroy

  def self.search(query)
    #__elasticsearch__.search(params[:q], [self, Category]).results.to_a.map(&:to_hash)
    __elasticsearch__.search(query) if query.present?
  end

  def self.to_table_array(data, aggs, final_table = nil, row = [])
    final_table = [aggs.keys] if final_table.nil?
    hash_tree = data.deep_find(aggs.keys.first)

    if aggs.values.uniq.length == 1 && aggs.values.uniq == [:data]
      aggs.keys.each do |agg|
        row << data[agg]["value"]
      end
      final_table << row
    else
      hash_tree["buckets"].each_with_index do |h, index|
        row.pop if index > 0
        aggs.shift if index == 0

        row << h["key_as_string"]
        final_table = to_table_array(h, aggs.clone, final_table, row.clone)
      end
    end

    final_table
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
end

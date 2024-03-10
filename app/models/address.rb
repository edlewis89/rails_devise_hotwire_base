class Address < ApplicationRecord
  belongs_to :addressable, polymorphic: true, touch: true

  #validates :city, presence: true
  #validates :state, presence: true
  validates :zipcode, presence: true

  after_commit :flush_cache

  def flush_cache
    Rails.cache.delete([self.class.name, id])
  end

  def self.cached_find(id)
    Rails.cache.fetch([name, id]) { find(id) }
  end
end

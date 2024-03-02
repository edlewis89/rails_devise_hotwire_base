class Homeowner < User
  has_many :homeowner_requests, dependent: :destroy
  has_one :profile, as: :profileable, dependent: :destroy, touch: true # Ensure the associated profile is destroyed when the homeowner is destroyed

  has_many :service_requests, as: :user

  #has_many :userable, polymorphic: true
  #belongs_to :user, :polymorphic => true
  #after_create :create_profile
  Rails.logger.info "#{name}: #{all.to_sql}"
  private
  #
  # def create_profile
  #   puts "Creating Homeowner #{self.class.name} Profile >>>>>>>>>>>>>>>"
  #   # Create a new profile associated with the homeowner
  #   build_profile unless profile
  #   profile.update(profileable_type: self.class.name.to_s)
  #   puts "Checking Profile Type #{profile.profileable_type} >>>>>>>>>>>>>>>"
  # end
end

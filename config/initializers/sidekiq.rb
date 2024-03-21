require 'sidekiq/web'
require 'sidekiq/cron'
require 'yaml'

# Assuming the YAML configuration is stored in a file named 'config/redis.yml'
REDIS_CONFIG = YAML.unsafe_load(File.open(Rails.root.join('config/redis.yml'))).deep_symbolize_keys

# Accessing the default configuration
default_config = REDIS_CONFIG[:default].deep_symbolize_keys # {:url=>"redis://localhost:6379", :db=>1}

# Printing out the default configuration
# puts default_config

# Accessing the URL for Redis in the production environment
production_url = REDIS_CONFIG[:production][:url]

# Assuming you want to merge the Redis URL with an environment variable
# You can create a Redis configuration hash like this

redis_cfg = {
  url: default_config[:url],
  timeout: 2.0
}

Sidekiq.configure_server do |config|
  config.redis = redis_cfg
  config.average_scheduled_poll_interval = 5
  config.on(:startup) do
    Sidekiq.strict_args!
  end
end

Sidekiq.configure_client do |config|
  config.redis = redis_cfg
end

schedule_file = "config/schedule.yml"

if File.exist?(schedule_file) && Sidekiq.server?
  Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
end
#
# Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_token]
# Sidekiq::Web.set :sessions, Rails.application.config.session_options
#
# Sidekiq.configure_server do |config|
#   config.error_handlers << Proc.new { |ex,ctx_hash| Airbrake.notify_or_ignore(ex, ctx_hash) }
# end


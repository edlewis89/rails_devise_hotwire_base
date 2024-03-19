require 'redis'

#redis = Redis.new(url: ENV['REDIS_HOST'])
#redis = Redis.new(host: "localhost", port: 6379, db: 11)
#redis.set("mykey", "hello world")
#redis.get("mykey")


#
# $redis = Redis.new
# url = ENV['REDIS_URL']
# if url
#   Sidekiq.configure_server do |config|
#   config.redis = { url: url }
# end
#   Sidekiq.configure_client do |config|
#     config.redis = { url: url }
#   end
#   $redis = Redis.new(:url => url)
# end


#config/initializers/redis.rb

REDIS_CONFIG = YAML.unsafe_load( File.open( Rails.root.join("config/redis.yml") ) ).symbolize_keys
dflt = REDIS_CONFIG[:default].symbolize_keys
cnfg = dflt.merge(REDIS_CONFIG[Rails.env.to_sym].symbolize_keys) if REDIS_CONFIG[Rails.env.to_sym]

$redis = Redis.new(cnfg)
#$redis_ns = Redis::Namespace.new(cnfg[:namespace], :redis => $redis) if cnfg[:namespace]

# To clear out the db before each test
$redis.flushdb if Rails.env == "test"

begin
  $redis.ping
rescue Redis::BaseError => e
  e.inspect
end
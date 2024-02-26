#Elasticsearch::Model.client = Elasticsearch::Client.new(url: ENV['ELASTICSEARCH_URL'] || 'http://localhost:9200', log: true)

#Elasticsearch::Model.client = Elasticsearch::Client.new hosts: hosts, transport_options: { ssl: { ca_file: '/etc/ssl/certs/cacert.pem' } }
#Elasticsearch::Model.client = Elasticsearch::Client.new hosts: 'https://localhost:9200', transport_options: { ssl: { verify: false } }
# client = OpenSearch::Client.new(host: 'http://localhost:9200')
# client = OpenSearch::Client.new(
#   url: "http://localhost:9200",
#   retry_on_failure: 5,
#   request_timeout: 120,
#   log: true
# )

#client.cluster.health

#Elasticsearch::Model.client = # Colons and uppercase/lowercase don't matter when using
# the 'ca_fingerprint' parameter
#CERT_FINGERPRINT = '64F2593F...'

# Password for the 'elastic' user generated by Elasticsearch
#ELASTIC_PASSWORD = "<password>"

# Elasticsearch::Model.client = Elasticsearch::Client.new(
#   host: "https://elastic:#{ENV["ELASTIC_PASSWORD"]}@localhost:9200",
#   transport_options: { ssl: { verify: false } },
#   ca_fingerprint: ENV["CERT_FINGERPRINT"]
# )


require 'elasticsearch'

#
# @client = Elasticsearch::Client.new(
#   url: "https://elastic:#{ENV['ELASTIC_PASSWORD']}@localhost:9200",
#   transport_options: {
#     ssl: {
#       ca_file: "/Volumes/Install\ macOS\ Sonoma/Projects/kibana-8.12.0/data/ca_1707023704536.crt",
#       verify: false # Set this to true if you have a valid CA file
#     }
#   },
#   headers: { 'Content-Type' => 'application/json' }, # Add this line to specify the content type
#   log: true # Set this to true if you want to enable logging
# )

# response = @client.ping
#
# puts "Connected to Elasticsearch: #{response}"
# @client.cluster.health
# Elasticsearch::Model.client = @client

module ElasticsearchHelper
  extend self

  def client
    @client ||= Elasticsearch::Client.new(
      url: "https://elastic:#{ENV['ELASTIC_PASSWORD']}@localhost:9200",
      transport_options: {
        ssl: {
          ca_file: "/Volumes/Install\ macOS\ Sonoma/Projects/kibana-8.12.0/data/ca_1707023704536.crt",
          verify: false
        }
      },
      headers: { 'Content-Type' => 'application/json' },
      log: true
    )

    Elasticsearch::Model.client = @client
  end

  def ping
    client.ping
  rescue Elasticsearch::Transport::Transport::Error => e
    puts "Error pinging Elasticsearch: #{e.message}"
  end

  def health_check
    client.cluster.health
  rescue Elasticsearch::Transport::Transport::Error => e
    puts "Error checking Elasticsearch health: #{e.message}"
  end

  def self.create_index_with_mappings!(index_name, mappings)
    unless index_exists?(index_name)
      client.indices.create(
        index: index_name,
        body: { mappings: mappings }
      )
      puts "Index '#{index_name}' created with mappings."
    else
      puts "Index '#{index_name}' already exists."
    end
  rescue Elasticsearch::Transport::Transport::Error => e
    puts "Error creating index '#{index_name}': #{e.message}"
  end

  def delete_index(index_name)
    if index_exists?(index_name)
      client.indices.delete(index: index_name)
      puts "Index '#{index_name}' deleted."
    else
      puts "Index '#{index_name}' does not exist."
    end
  rescue Elasticsearch::Transport::Transport::Error => e
    puts "Error deleting index '#{index_name}': #{e.message}"
  end

  # Method to search Elasticsearch only if index exists
  def search_if_index_exists(index_name, query)
    if index_exists?(index_name)
      binding.pry
      client.search(index: index_name, body: { query: { match: { _all: query } } })
    else
      puts "Index '#{index_name}' does not exist."
      nil
    end
  end

  def index_exists?(index_name)
    client.indices.exists(index: index_name)
  rescue Elasticsearch::Transport::Transport::Error => e
    puts "Error checking index existence: #{e.message}"
    false
  end

  def ensure_index_exists(index_name)
    unless index_exists?(index_name)
      create_index(index_name)
    end
  end

  # Method to view mappings of an Elasticsearch index
  def view_index_mappings(index_name)
    mappings = client.indices.get_mapping(index: index_name)
    puts "Mappings for index '#{index_name}':"
    puts mappings.to_json
  end


end
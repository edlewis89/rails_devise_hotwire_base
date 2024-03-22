# # Access the ElasticsearchHelper instance
# elasticsearch_helper = ElasticsearchHelper.instance
#
# # Ping Elasticsearch to check if it's reachable
# elasticsearch_helper.ping
#
# # Perform a health check to get information about Elasticsearch cluster health
# elasticsearch_helper.health_check
#
# # Create an index with mappings
# index_name = "example_index"
# mappings = {
#   properties: {
#     name: { type: 'text' },
#     age: { type: 'integer' },
#     email: { type: 'text' }
#   }
# }
# elasticsearch_helper.create_index_with_mappings!(index_name, mappings)
#
# # Search for documents in the index
# query = "John"
# fields = ["name", "email"]
# response = elasticsearch_helper.search_if_index_exists(index_name, query, fields)
# puts response
#
# # Delete the index
# elasticsearch_helper.delete_index(index_name)
#
require 'elasticsearch'
require 'singleton'
require 'logger'

class ElasticsearchHelper
  include Singleton

  attr_reader :client

  def initialize
    @client = build_client
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

  def create_index_with_mappings!(index_name, mappings)
    unless index_exists?(index_name)
      client.indices.create(index: index_name, body: { mappings: mappings })
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

  def search_if_index_exists(index_name, query, fields)
    raise "Index '#{index_name}' does not exist." unless index_exists?(index_name)

    body_query = build_generic_query(query, fields)
    puts " >>>>>>>>>>>>>>>>#{index_name} #{body_query}"

    client.search(index: index_name, body: body_query)
  rescue Elasticsearch::Transport::Transport::Errors::BadRequest => e
    puts "Error performing search: #{e.message}"
    nil
  rescue => e
    puts "An error occurred: #{e.message}"
    nil
  end

  def index_exists?(index_name)
    client.indices.exists(index: index_name)
  rescue Elasticsearch::Transport::Transport::Error => e
    puts "Error checking index existence: #{e.message}"
    false
  end

  def ensure_index_exists(index_name)
    create_index(index_name) unless index_exists?(index_name)
  end

  def view_index_mappings(index_name)
    mappings = client.indices.get_mapping(index: index_name)
    puts "Mappings for index '#{index_name}':"
    puts mappings.to_json
  end

  def document_exists?(index_name, document_id)
    client.exists?(index: index_name, id: document_id)
  rescue Elasticsearch::Transport::Transport::Error => e
    puts "Error checking document existence: #{e.message}"
    false
  end

  private

  def build_client
    Elasticsearch::Client.new(
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
  rescue Elasticsearch::Transport::Transport::Error => e
    @logger.error("Error building Elasticsearch client: #{e.message}")
    raise e
  end

  def elasticsearch_url
    ENV['ELASTIC_URL'] || "https://elastic:#{ENV['ELASTIC_PASSWORD']}@localhost:9200"
  end

  def build_generic_query(query, fields)
    query_hash = {
      query: {
        multi_match: {
          query: query,
          fields: fields
        }
      }
    }

    # Print out the constructed query for inspection
    puts "Constructed query: #{query_hash.inspect}"

    # Return the constructed query
    query_hash
  end
end

module Rentabud
  module Elasticsearch
    extend self
    attr_accessor :config

    # @return [Elasticsearch::Transport::Client]
    def client
      @client ||= ElasticsearchHelper.instance.client
    end
  end
end

# Use the ElasticsearchHelper to access the client
helper_instance = ElasticsearchHelper.instance
helper_instance.ping
helper_instance.health_check

Elasticsearch::Model.client = ElasticsearchHelper.instance.client

helper_instance.search_if_index_exists("profiles","homeowner@example.com",['email'])

Elasticsearch::Model.client = helper_instance.client
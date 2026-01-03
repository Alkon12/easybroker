require 'faraday'
require_relative 'configuration'
require_relative 'error'
require_relative 'rate_limiter'

module EasyBroker
  # Main API client for interacting with the EasyBroker API
  class Client
    attr_reader :config

    # Initialize a new EasyBroker client
    # @param api_key [String] API key for authentication
    # @param base_url [String] Base URL for the API
    def initialize(api_key: nil, base_url: nil)
      @config = Configuration.new(api_key: api_key, base_url: base_url)
      @config.validate!
      @connection = build_connection
    end

    # Access to Properties resource
    # @return [Resources::Properties]
    def properties
      @properties ||= Resources::Properties.new(self)
    end

    # Access to Locations resource
    # @return [Resources::Locations]
    def locations
      @locations ||= Resources::Locations.new(self)
    end

    # Perform a GET request
    # @param path [String] API endpoint path
    # @param params [Hash] Query parameters
    # @return [Hash] Parsed JSON response
    def get(path, params = {})
      request(:get, path, params)
    end

    # Perform a POST request
    # @param path [String] API endpoint path
    # @param body [Hash] Request body
    # @return [Hash] Parsed JSON response
    def post(path, body = {})
      request(:post, path, {}, body)
    end

    # Perform a PATCH request
    # @param path [String] API endpoint path
    # @param body [Hash] Request body
    # @return [Hash] Parsed JSON response
    def patch(path, body = {})
      request(:patch, path, {}, body)
    end

    # Perform a DELETE request
    # @param path [String] API endpoint path
    # @return [Hash] Parsed JSON response
    def delete(path)
      request(:delete, path)
    end

    private

    attr_reader :connection

    def request(method, path, params = {}, body = nil)
      RateLimiter.throttle do
        response = connection.public_send(method) do |req|
          req.url(path)
          req.params.update(params) if params.any?
          req.body = body.to_json if body
        end

        handle_response(response)
      end
    rescue Faraday::TimeoutError => e
      raise Timeout, "Request timed out: #{e.message}"
    rescue Faraday::ConnectionFailed => e
      raise ServerError, "Connection failed: #{e.message}"
    end

    def build_connection
      Faraday.new(url: config.base_url) do |f|
        f.headers['X-Authorization'] = config.api_key
        f.headers['Accept'] = 'application/json'

        f.request :json
        f.response :json, parser_options: { symbolize_names: false }

        # Set timeouts
        f.options.timeout = 30
        f.options.open_timeout = 10

        f.adapter Faraday.default_adapter
      end
    end

    def handle_response(response)
      case response.status
      when 200..299
        body = response.body
        # Handle empty or nil body (e.g., 204 No Content)
        return {} if body.nil? || body == ''
        body.is_a?(Hash) ? body : {}
      when 401
        raise Unauthorized, 'Invalid or missing API key'
      when 404
        raise NotFound, 'Resource not found'
      when 429
        raise RateLimitExceeded, 'Rate limit exceeded (20 requests/second)'
      when 400..499
        raise ClientError, "Client error (#{response.status}): #{response.body}"
      when 500..599
        raise ServerError, "Server error (#{response.status}): #{response.body}"
      else
        raise Error, "Unexpected response (#{response.status}): #{response.body}"
      end
    end
  end
end

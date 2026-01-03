require_relative 'base'
require_relative '../models/location'
require_relative '../models/pagination'
require_relative '../models/paginated_response'

module EasyBroker
  module Resources
    # Handles API requests for locations
    class Locations < Base
      # List locations with optional search
      # @param search [String] Optional search term for location names
      # @param page [Integer] Page number (default: 1)
      # @param limit [Integer] Items per page, max 50 (default: 20)
      # @return [Models::PaginatedResponse]
      def list(search: nil, page: 1, limit: 20)
        validate_page!(page)
        validate_limit!(limit)

        params = pagination_params(page, limit)
        params[:search] = search if search

        response = client.get('/locations', params)

        parse_paginated_response(response, Models::Location)
      end

      # Search locations by name
      # @param query [String] Search query
      # @param page [Integer] Page number
      # @param limit [Integer] Items per page
      # @return [Models::PaginatedResponse]
      def search(query, page: 1, limit: 20)
        list(search: query, page: page, limit: limit)
      end

      # Find a specific location by ID
      # @param id [String, Integer] Location ID
      # @return [Models::Location]
      def find(id)
        response = client.get("/locations/#{id}")
        Models::Location.new(response)
      end
    end
  end
end

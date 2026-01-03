require_relative 'base'
require_relative '../models/property'
require_relative '../models/pagination'
require_relative '../models/paginated_response'

module EasyBroker
  module Resources
    # Handles API requests for properties
    class Properties < Base
      # List properties with optional filters and pagination
      # @param page [Integer] Page number (default: 1)
      # @param limit [Integer] Items per page, max 50 (default: 20)
      # @param filters [Hash] Optional filters
      # @option filters [Array<String>] :property_types Filter by property types
      # @option filters [Array<String>] :statuses Filter by statuses
      # @option filters [String] :search General search term
      # @option filters [Integer] :bedrooms Minimum bedrooms
      # @option filters [Integer] :bathrooms Minimum bathrooms
      # @option filters [Integer] :parking_spaces Minimum parking spaces
      # @option filters [Integer, Float] :min_price Minimum price
      # @option filters [Integer, Float] :max_price Maximum price
      # @option filters [Integer, Float] :min_construction_size Minimum construction size
      # @option filters [Integer, Float] :max_construction_size Maximum construction size
      # @option filters [String] :updated_at_from Filter properties updated after this date
      # @option filters [String] :updated_at_to Filter properties updated before this date
      # @return [Models::PaginatedResponse]
      def list(page: 1, limit: 20, filters: {})
        validate_page!(page)
        validate_limit!(limit)

        params = pagination_params(page, limit).merge(sanitize_filters(filters))
        response = client.get('/properties', params)

        parse_paginated_response(response, Models::Property)
      end

      # Find a specific property by ID
      # @param id [String, Integer] Property ID or public ID
      # @return [Models::Property]
      def find(id)
        response = client.get("/properties/#{id}")
        Models::Property.new(response)
      end

      # Search properties (alias for list with search filter)
      # @param query [String] Search query
      # @param page [Integer] Page number
      # @param limit [Integer] Items per page
      # @return [Models::PaginatedResponse]
      def search(query, page: 1, limit: 20)
        list(page: page, limit: limit, filters: { search: query })
      end

      private

      def sanitize_filters(filters)
        allowed_keys = %i[
          property_types statuses search
          bedrooms bathrooms parking_spaces half_bathrooms
          min_price max_price
          min_construction_size max_construction_size
          min_lot_size max_lot_size
          updated_at_from updated_at_to
        ]

        sanitized = {}

        filters.each do |key, value|
          sym_key = key.to_sym
          next unless allowed_keys.include?(sym_key)
          next if value.nil?

          # Convert arrays to proper format for API
          if value.is_a?(Array) && [:property_types, :statuses].include?(sym_key)
            sanitized["search[#{sym_key}]"] = value
          elsif sym_key == :search
            sanitized[sym_key] = value
          else
            # Other filters go into search hash
            sanitized["search[#{sym_key}]"] = value
          end
        end

        sanitized
      end
    end
  end
end

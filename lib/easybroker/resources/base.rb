module EasyBroker
  module Resources
    # Base class for all API resources
    class Base
      attr_reader :client

      def initialize(client)
        @client = client
      end

      private

      # Validate pagination limit (EasyBroker max is 50)
      def validate_limit!(limit)
        unless limit.is_a?(Integer) && limit.between?(1, 50)
          raise ArgumentError, 'Limit must be between 1 and 50'
        end
      end

      # Validate page number
      def validate_page!(page)
        unless page.is_a?(Integer) && page.positive?
          raise ArgumentError, 'Page must be a positive integer'
        end
      end

      # Build pagination params
      def pagination_params(page, limit)
        {
          page: page,
          limit: limit
        }
      end

      # Parse paginated response
      def parse_paginated_response(response, model_class)
        content = response['content'] || []
        pagination_data = response['pagination'] || {}

        Models::PaginatedResponse.new(
          data: content.map { |item| model_class.new(item) },
          pagination: Models::Pagination.new(pagination_data),
          total: response['total']
        )
      end
    end
  end
end

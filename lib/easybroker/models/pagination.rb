module EasyBroker
  module Models
    # Represents pagination metadata from API responses
    class Pagination
      attr_reader :page, :limit, :total, :next_page

      def initialize(data = {})
        @page = data['page'] || 1
        @limit = data['limit'] || 20
        @total = data['total'] || 0
        @next_page = data['next_page']
      end

      # Check if there are more pages available
      # @return [Boolean]
      def next_page?
        !next_page.nil?
      end

      # Extract page number from next_page URL
      # The API returns next_page as a full URL like:
      # "https://api.stagingeb.com/v1/properties?limit=20&page=2"
      # This method extracts the page number (2 in this example)
      # @return [Integer, nil]
      def next_page_number
        return nil unless next_page

        # If next_page is already a number, return it
        return next_page if next_page.is_a?(Integer)

        # Extract page number from URL
        if next_page.is_a?(String) && next_page.include?('page=')
          match = next_page.match(/[?&]page=(\d+)/)
          match ? match[1].to_i : nil
        end
      end

      # Calculate total number of pages
      # @return [Integer]
      def total_pages
        return 0 if total.zero? || limit.zero?
        (total.to_f / limit).ceil
      end

      # Check if this is the first page
      # @return [Boolean]
      def first_page?
        page == 1
      end

      # Check if this is the last page
      # @return [Boolean]
      def last_page?
        !next_page?
      end

      def to_h
        {
          page: page,
          limit: limit,
          total: total,
          next_page: next_page,
          total_pages: total_pages
        }
      end
    end
  end
end

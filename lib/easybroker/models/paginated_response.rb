module EasyBroker
  module Models
    # Wraps a paginated API response with data and pagination metadata
    class PaginatedResponse
      attr_reader :data, :pagination, :total

      def initialize(data:, pagination:, total: nil)
        @data = data
        @pagination = pagination
        @total = total || pagination.total
      end

      # Iterator for data items
      def each(&block)
        data.each(&block)
      end

      # Check if response has any data
      # @return [Boolean]
      def empty?
        data.empty?
      end

      # Number of items in current page
      # @return [Integer]
      def count
        data.count
      end
      alias_method :size, :count
      alias_method :length, :count

      # Access data by index
      def [](index)
        data[index]
      end

      def to_a
        data
      end

      def to_h
        {
          data: data.map { |item| item.respond_to?(:to_h) ? item.to_h : item },
          pagination: pagination.to_h,
          total: total
        }
      end
    end
  end
end

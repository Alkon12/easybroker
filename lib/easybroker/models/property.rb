module EasyBroker
  module Models
    # Represents a property from the EasyBroker API
    class Property
      attr_reader :id, :public_id, :title, :description, :property_type,
                  :operations, :bedrooms, :bathrooms, :half_bathrooms,
                  :parking_spaces, :construction_size, :lot_size,
                  :location, :address, :neighborhood, :city, :state,
                  :price, :currency, :property_images, :videos,
                  :updated_at, :created_at, :show_prices, :share_commission,
                  :internal_id, :agent, :title_image_full, :title_image_thumb

      def initialize(attributes = {})
        @id = attributes['id']
        @public_id = attributes['public_id']
        @title = attributes['title']
        @description = attributes['description']
        @property_type = attributes['property_type']
        @operations = attributes['operations'] || []

        @bedrooms = attributes['bedrooms']
        @bathrooms = attributes['bathrooms']
        @half_bathrooms = attributes['half_bathrooms']
        @parking_spaces = attributes['parking_spaces']

        @construction_size = attributes['construction_size']
        @lot_size = attributes['lot_size']

        @location = attributes['location']
        @address = attributes['address']
        @neighborhood = attributes['neighborhood']
        @city = attributes['city']
        @state = attributes['state']

        # Extract price and currency from operations array
        # Prefer sale operation, fallback to first operation
        @primary_operation = extract_primary_operation
        @price = @primary_operation&.dig('amount')
        @currency = @primary_operation&.dig('currency')
        @formatted_amount = @primary_operation&.dig('formated_amount')

        @show_prices = attributes['show_prices']
        @share_commission = attributes['share_commission']

        @property_images = attributes['property_images'] || []
        @videos = attributes['videos'] || []

        # Images from list endpoint
        @title_image_full = attributes['title_image_full']
        @title_image_thumb = attributes['title_image_thumb']

        @updated_at = parse_time(attributes['updated_at'])
        @created_at = parse_time(attributes['created_at'])

        @internal_id = attributes['internal_id']
        @agent = attributes['agent']
      end

      # Get the main/first property image URL
      # Returns title_image_full from list endpoint, or first property_image from detail endpoint
      # @return [String, nil]
      def main_image
        title_image_full || property_images.first&.dig('url')
      end

      # Get the thumbnail image URL (used in list views)
      # @return [String, nil]
      def thumbnail_image
        title_image_thumb || title_image_full || property_images.first&.dig('url')
      end

      # Get all image URLs
      # @return [Array<String>]
      def image_urls
        property_images.map { |img| img['url'] }.compact
      end

      # Format price with currency symbol and thousands separator
      # @return [String]
      def formatted_price
        return 'Price on request' if price.nil? || !show_prices

        # Use API's formatted amount if available
        return @formatted_amount if @formatted_amount

        # Fallback to manual formatting
        symbol = currency_symbol
        amount = format_number(price)

        "#{symbol}#{amount}"
      end

      # Check if property is for sale
      # @return [Boolean]
      def for_sale?
        operations.any? { |op| op['type'] == 'sale' }
      end

      # Check if property is for rent
      # @return [Boolean]
      def for_rent?
        operations.any? { |op| op['type'] == 'rental' || op['type'] == 'temporary_rental' }
      end

      # Get operation types as human-readable string
      # @return [String]
      def operation_types
        types = []
        types << 'For Sale' if for_sale?
        types << 'For Rent' if for_rent?
        types.join(' / ')
      end

      # Get full location string
      # @return [String]
      def full_location
        parts = [neighborhood, city, state].compact
        parts.any? ? parts.join(', ') : location
      end

      # Property summary for display
      # @return [String]
      def summary
        parts = []
        parts << "#{bedrooms} bed" if bedrooms && bedrooms > 0
        parts << "#{bathrooms} bath" if bathrooms && bathrooms > 0
        parts << "#{parking_spaces} parking" if parking_spaces && parking_spaces > 0
        parts.join(' • ')
      end

      # Convert to hash
      def to_h
        {
          id: id,
          public_id: public_id,
          title: title,
          description: description,
          property_type: property_type,
          operations: operations,
          bedrooms: bedrooms,
          bathrooms: bathrooms,
          half_bathrooms: half_bathrooms,
          parking_spaces: parking_spaces,
          construction_size: construction_size,
          lot_size: lot_size,
          location: location,
          address: address,
          neighborhood: neighborhood,
          city: city,
          state: state,
          price: price,
          currency: currency,
          formatted_price: formatted_price,
          property_images: property_images,
          videos: videos,
          updated_at: updated_at,
          created_at: created_at
        }
      end

      private

      def extract_primary_operation
        return nil if operations.empty?

        # Prefer sale operation, otherwise use first operation
        operations.find { |op| op['type'] == 'sale' } || operations.first
      end

      def parse_time(time_string)
        return nil if time_string.nil?
        Time.parse(time_string)
      rescue ArgumentError
        nil
      end

      def currency_symbol
        case currency&.upcase
        when 'USD' then '$'
        when 'MXN' then '$'
        when 'EUR' then '€'
        when 'GBP' then '£'
        else '$'
        end
      end

      def format_number(number)
        number.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
      end
    end
  end
end

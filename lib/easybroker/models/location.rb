module EasyBroker
  module Models
    # Represents a location from the EasyBroker API
    class Location
      attr_reader :id, :name, :full_name, :type, :localities, :parent_id

      def initialize(attributes = {})
        @id = attributes['id']
        @name = attributes['name']
        @full_name = attributes['full_name']
        @type = attributes['type']
        @localities = (attributes['localities'] || []).map { |loc| self.class.new(loc) }
        @parent_id = attributes['parent_id']
      end

      # Check if location has child localities
      # @return [Boolean]
      def has_localities?
        localities.any?
      end

      # Get number of child localities
      # @return [Integer]
      def localities_count
        localities.count
      end

      # Check if this is a country
      # @return [Boolean]
      def country?
        type&.downcase == 'country'
      end

      # Check if this is a state/province
      # @return [Boolean]
      def state?
        type&.downcase == 'state' || type&.downcase == 'province'
      end

      # Check if this is a city
      # @return [Boolean]
      def city?
        type&.downcase == 'city'
      end

      # Check if this is a neighborhood
      # @return [Boolean]
      def neighborhood?
        type&.downcase == 'neighborhood' || type&.downcase == 'colonia'
      end

      # Get human-readable type
      # @return [String]
      def type_label
        return 'Unknown' unless type

        case type.downcase
        when 'country' then 'Country'
        when 'state', 'province' then 'State'
        when 'city' then 'City'
        when 'neighborhood', 'colonia' then 'Neighborhood'
        else type.capitalize
        end
      end

      # Get display name (uses full_name if available, otherwise name)
      # @return [String]
      def display_name
        full_name || name
      end

      # Convert to hash
      def to_h
        {
          id: id,
          name: name,
          full_name: full_name,
          type: type,
          type_label: type_label,
          localities: localities.map(&:to_h),
          localities_count: localities_count
        }
      end

      # Recursively flatten all localities into a single array
      # @return [Array<Location>]
      def all_localities
        result = localities.dup
        localities.each do |locality|
          result.concat(locality.all_localities)
        end
        result
      end
    end
  end
end

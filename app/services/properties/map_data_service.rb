module Properties
  # Service to fetch property map data with coordinates
  # This service handles the complexity of fetching individual properties
  # to get coordinates, which are not available in the list endpoint
  class MapDataService
    # Maximum properties to show on map to balance UX and performance
    MAX_MAP_PROPERTIES = 30
    # Cache TTL: 10 minutes to reduce API calls while keeping data reasonably fresh
    CACHE_TTL = 10.minutes

    def initialize(limit: MAX_MAP_PROPERTIES)
      @limit = [limit, MAX_MAP_PROPERTIES].min
    end

    def call
      # Use Rails cache to avoid excessive API calls
      # Cache key includes limit to ensure different limits are cached separately
      Rails.cache.fetch(cache_key, expires_in: CACHE_TTL) do
        fetch_map_data
      end
    rescue EasyBroker::Error => e
      error_result(e.message)
    end

    private

    def cache_key
      "properties/map_data/limit_#{@limit}"
    end

    def fetch_map_data
      client = easybroker_client

      # Step 1: Get list of properties (only IDs and basic data)
      properties_list = fetch_properties_list(client)
      return error_result('No properties found') if properties_list.empty?

      # Step 2: Fetch detailed data for each property (includes coordinates)
      # The rate limiter will automatically throttle to 20 req/sec
      properties_with_coords = fetch_detailed_properties(client, properties_list)

      # Step 3: Filter out properties without coordinates
      valid_properties = properties_with_coords.select { |p| has_coordinates?(p) }

      {
        properties: valid_properties.map { |p| map_property_data(p) },
        total_fetched: properties_list.count,
        valid_count: valid_properties.count,
        success: true
      }
    end

    def easybroker_client
      @client ||= EasyBroker::Client.new
    end

    def fetch_properties_list(client)
      # Get first page with limit
      result = client.properties.list(page: 1, limit: @limit)
      result.data
    end

    def fetch_detailed_properties(client, properties_list)
      # Fetch details for each property
      # Rate limiter handles throttling automatically
      properties_list.map do |property|
        begin
          client.properties.find(property.public_id || property.id)
        rescue EasyBroker::NotFound
          # Property might have been deleted, skip it
          nil
        rescue EasyBroker::Error => e
          # Log error but continue with other properties
          Rails.logger.error("Failed to fetch property #{property.id}: #{e.message}")
          nil
        end
      end.compact
    end

    def has_coordinates?(property)
      property.location &&
        property.location['latitude'] &&
        property.location['longitude']
    end

    def map_property_data(property)
      {
        id: property.id,
        public_id: property.public_id,
        latitude: property.location['latitude'],
        longitude: property.location['longitude'],
        title: property.title,
        thumbnail: property.thumbnail_image,
        price: property.formatted_price,
        summary: property.summary,
        full_location: property.full_location,
        operation_types: property.operation_types,
        url: Rails.application.routes.url_helpers.property_path(property.public_id || property.id)
      }
    end

    def error_result(message)
      {
        properties: [],
        total_fetched: 0,
        valid_count: 0,
        success: false,
        error: message
      }
    end
  end
end

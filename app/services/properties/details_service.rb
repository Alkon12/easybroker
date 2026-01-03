module Properties
  # Service to fetch a single property from EasyBroker API
  class DetailsService
    def initialize(property_id)
      @property_id = property_id
    end

    def call
      client = easybroker_client
      property = client.properties.find(@property_id)

      {
        property: property,
        success: true
      }
    rescue EasyBroker::NotFound
      {
        property: nil,
        success: false,
        error: 'Property not found'
      }
    rescue EasyBroker::Error => e
      {
        property: nil,
        success: false,
        error: e.message
      }
    end

    private

    def easybroker_client
      @client ||= EasyBroker::Client.new
    end
  end
end

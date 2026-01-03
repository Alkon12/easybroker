module EasyBroker
  class Configuration
    attr_accessor :api_key, :base_url

    def initialize(api_key: nil, base_url: nil)
      @api_key = api_key || ENV.fetch('EASYBROKER_API_KEY', nil)
      @base_url = base_url || ENV.fetch('EASYBROKER_BASE_URL', 'https://api.stagingeb.com')
    end

    def valid?
      !api_key.nil? && !api_key.empty?
    end

    def validate!
      raise Error, 'API key is required' unless valid?
    end
  end
end

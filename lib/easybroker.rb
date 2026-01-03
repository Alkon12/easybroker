# Main entry point for the EasyBroker API client
# Note: We use EasyBroker (camelCase) to differentiate from the Rails app module Easybroker

# Load core classes first
require_relative 'easybroker/error'
require_relative 'easybroker/configuration'
require_relative 'easybroker/rate_limiter'

# Define the module
module EasyBroker
  # Resources namespace
  module Resources
  end

  # Models namespace
  module Models
  end
end

# Load models
require_relative 'easybroker/models/pagination'
require_relative 'easybroker/models/paginated_response'
require_relative 'easybroker/models/property'
require_relative 'easybroker/models/location'

# Load resources
require_relative 'easybroker/resources/base'
require_relative 'easybroker/resources/properties'
require_relative 'easybroker/resources/locations'

# Load client after everything is defined
require_relative 'easybroker/client'

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

# Load client after module is defined
require_relative 'easybroker/client'

# EasyBroker API Client Configuration
# This initializer explicitly loads the EasyBroker client library

# The lib/easybroker library uses explicit require_relative to remain framework-agnostic,
# so we need to manually require it during initialization to make constants available
# to controllers and services that reference them at class definition time.
require Rails.root.join('lib', 'easybroker')

# Configuration will be set when EasyBroker::Client is first instantiated
# Default values can be provided via environment variables:
# - EASYBROKER_API_KEY
# - EASYBROKER_BASE_URL (defaults to https://api.stagingeb.com/v1)

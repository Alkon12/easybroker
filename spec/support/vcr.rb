require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!

  # Filter sensitive data
  config.filter_sensitive_data('<EASYBROKER_API_KEY>') { ENV['EASYBROKER_API_KEY'] }
  config.filter_sensitive_data('<EASYBROKER_API_KEY>') { 'l7u502p8v46ba3ppgvj5y2aad50lb9' }

  # Default cassette options
  config.default_cassette_options = {
    record: :once,
    match_requests_on: [:method, :uri, :body]
  }

  # Allow localhost connections (for Rails server in tests)
  config.ignore_localhost = true

  # Ignore any requests to these hosts
  config.ignore_hosts 'chromedriver.storage.googleapis.com'
end

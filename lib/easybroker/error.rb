module EasyBroker
  # Base error class for all EasyBroker API errors
  class Error < StandardError; end

  # Raised when API key is invalid or missing (HTTP 401)
  class Unauthorized < Error; end

  # Raised when a resource is not found (HTTP 404)
  class NotFound < Error; end

  # Raised when rate limit is exceeded (HTTP 429)
  class RateLimitExceeded < Error; end

  # Raised when server returns an error (HTTP 5xx)
  class ServerError < Error; end

  # Raised when client request is invalid (HTTP 4xx)
  class ClientError < Error; end

  # Raised when API response is invalid or malformed
  class InvalidResponse < Error; end

  # Raised when request times out
  class Timeout < Error; end
end

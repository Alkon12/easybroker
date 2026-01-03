module EasyBroker
  # Thread-safe rate limiter to enforce EasyBroker's 20 requests/second limit
  class RateLimiter
    MAX_REQUESTS = 20
    TIME_WINDOW = 1.0 # seconds

    class << self
      # Throttle a block of code to respect rate limits
      # @yield The block to execute
      # @return The result of the block
      def throttle
        wait_if_needed
        record_request
        yield
      end

      # Reset the rate limiter (useful for testing)
      def reset!
        @recent_requests = nil
        @requests_mutex = nil
      end

      private

      def wait_if_needed
        requests_mutex.synchronize do
          now = current_time

          # Remove requests older than the time window
          recent_requests.reject! { |time| now - time > TIME_WINDOW }

          # If we've hit the limit, wait until the oldest request expires
          if recent_requests.size >= MAX_REQUESTS
            sleep_time = TIME_WINDOW - (now - recent_requests.first)
            sleep(sleep_time) if sleep_time > 0
            recent_requests.shift
          end
        end
      end

      def record_request
        requests_mutex.synchronize do
          recent_requests << current_time
        end
      end

      def recent_requests
        @recent_requests ||= []
      end

      def requests_mutex
        @requests_mutex ||= Mutex.new
      end

      def current_time
        Time.now.to_f
      end
    end
  end
end

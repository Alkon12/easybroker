require 'rails_helper'

RSpec.describe EasyBroker::RateLimiter do
  before { described_class.reset! }
  after { described_class.reset! }

  describe '.throttle' do
    it 'executes the block and returns its value' do
      result = described_class.throttle { 'test_result' }
      expect(result).to eq('test_result')
    end

    it 'allows up to MAX_REQUESTS within TIME_WINDOW' do
      start_time = Time.now

      described_class::MAX_REQUESTS.times do
        described_class.throttle { 'ok' }
      end

      elapsed = Time.now - start_time
      expect(elapsed).to be < 0.5 # Should be fast
    end

    it 'throttles requests when limit is exceeded' do
      start_time = Time.now

      # Make MAX_REQUESTS + 1 requests
      (described_class::MAX_REQUESTS + 1).times do
        described_class.throttle { 'ok' }
      end

      elapsed = Time.now - start_time
      # Should take at least some time because it had to wait
      expect(elapsed).to be >= 0.01
    end

    it 'is thread-safe' do
      results = []
      threads = []

      5.times do
        threads << Thread.new do
          5.times do
            result = described_class.throttle { rand(100) }
            results << result
          end
        end
      end

      threads.each(&:join)
      expect(results.length).to eq(25)
    end
  end

  describe '.reset!' do
    it 'clears recent requests' do
      5.times { described_class.throttle { 'ok' } }

      described_class.reset!

      # After reset, should be able to make MAX_REQUESTS quickly again
      start_time = Time.now
      described_class::MAX_REQUESTS.times do
        described_class.throttle { 'ok' }
      end
      elapsed = Time.now - start_time

      expect(elapsed).to be < 0.5
    end
  end
end

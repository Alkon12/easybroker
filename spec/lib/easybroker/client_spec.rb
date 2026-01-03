require 'rails_helper'

RSpec.describe EasyBroker::Client do
  let(:api_key) { 'test_api_key' }
  let(:base_url) { 'https://api.test.com' }
  let(:client) { described_class.new(api_key: api_key, base_url: base_url) }

  before { EasyBroker::RateLimiter.reset! }
  after { EasyBroker::RateLimiter.reset! }

  describe '#initialize' do
    it 'creates a client with valid configuration' do
      expect(client.config.api_key).to eq(api_key)
      expect(client.config.base_url).to eq(base_url)
    end

    it 'raises error when API key is missing' do
      ENV.delete('EASYBROKER_API_KEY')

      expect {
        described_class.new(api_key: nil, base_url: base_url)
      }.to raise_error(EasyBroker::Error, 'API key is required')
    end
  end

  describe '#get' do
    it 'performs a GET request successfully' do
      stub_request(:get, "#{base_url}/test")
        .with(headers: { 'X-Authorization' => api_key })
        .to_return(
          status: 200,
          body: { data: 'test' }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      result = client.get('/test')

      expect(result).to eq({ 'data' => 'test' })
    end

    it 'includes query parameters' do
      stub_request(:get, "#{base_url}/test?page=1&limit=10")
        .with(headers: { 'X-Authorization' => api_key })
        .to_return(
          status: 200,
          body: {}.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      client.get('/test', page: 1, limit: 10)

      expect(WebMock).to have_requested(:get, "#{base_url}/test?page=1&limit=10")
    end

    it 'raises Unauthorized on 401 response' do
      stub_request(:get, "#{base_url}/test")
        .to_return(status: 401)

      expect {
        client.get('/test')
      }.to raise_error(EasyBroker::Unauthorized, 'Invalid or missing API key')
    end

    it 'raises NotFound on 404 response' do
      stub_request(:get, "#{base_url}/test")
        .to_return(status: 404)

      expect {
        client.get('/test')
      }.to raise_error(EasyBroker::NotFound, 'Resource not found')
    end

    it 'raises RateLimitExceeded on 429 response' do
      stub_request(:get, "#{base_url}/test")
        .to_return(status: 429)

      expect {
        client.get('/test')
      }.to raise_error(EasyBroker::RateLimitExceeded, 'Rate limit exceeded (20 requests/second)')
    end

    it 'raises ClientError on 4xx response' do
      stub_request(:get, "#{base_url}/test")
        .to_return(status: 400, body: 'Bad request')

      expect {
        client.get('/test')
      }.to raise_error(EasyBroker::ClientError, /Client error \(400\)/)
    end

    it 'raises ServerError on 5xx response' do
      stub_request(:get, "#{base_url}/test")
        .to_return(status: 500, body: 'Internal error')

      expect {
        client.get('/test')
      }.to raise_error(EasyBroker::ServerError, /Server error \(500\)/)
    end
  end

  describe '#post' do
    it 'performs a POST request with body' do
      stub_request(:post, "#{base_url}/test")
        .with(
          body: { name: 'test' }.to_json,
          headers: { 'X-Authorization' => api_key, 'Content-Type' => 'application/json' }
        )
        .to_return(
          status: 201,
          body: { id: 1 }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      result = client.post('/test', { name: 'test' })

      expect(result).to eq({ 'id' => 1 })
    end
  end

  describe '#patch' do
    it 'performs a PATCH request with body' do
      stub_request(:patch, "#{base_url}/test/1")
        .with(
          body: { name: 'updated' }.to_json,
          headers: { 'X-Authorization' => api_key, 'Content-Type' => 'application/json' }
        )
        .to_return(
          status: 200,
          body: { id: 1, name: 'updated' }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      result = client.patch('/test/1', { name: 'updated' })

      expect(result).to eq({ 'id' => 1, 'name' => 'updated' })
    end
  end

  describe '#delete' do
    it 'performs a DELETE request' do
      stub_request(:delete, "#{base_url}/test/1")
        .with(headers: { 'X-Authorization' => api_key })
        .to_return(status: 204, body: '', headers: {})

      result = client.delete('/test/1')

      expect(result).to eq({})
    end
  end

  describe 'rate limiting integration' do
    it 'throttles requests through RateLimiter' do
      stub_request(:get, "#{base_url}/test")
        .to_return(status: 200, body: {}.to_json)

      expect(EasyBroker::RateLimiter).to receive(:throttle).exactly(3).times.and_call_original

      3.times { client.get('/test') }
    end
  end
end

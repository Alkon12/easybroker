require 'rails_helper'

RSpec.describe EasyBroker::Resources::Locations do
  let(:api_key) { 'test_api_key' }
  let(:base_url) { 'https://api.test.com' }
  let(:client) { EasyBroker::Client.new(api_key: api_key, base_url: base_url) }
  let(:locations) { described_class.new(client) }

  before { EasyBroker::RateLimiter.reset! }
  after { EasyBroker::RateLimiter.reset! }

  describe '#list' do
    let(:response_body) do
      {
        'content' => [sample_location_data, sample_location_data.merge('id' => '2', 'name' => 'Another City')],
        'pagination' => { 'page' => 1, 'limit' => 20, 'total' => 2, 'next_page' => nil },
        'total' => 2
      }
    end

    it 'returns paginated locations' do
      stub_request(:get, "#{base_url}/locations?page=1&limit=20")
        .to_return(
          status: 200,
          body: response_body.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      result = locations.list

      expect(result).to be_a(EasyBroker::Models::PaginatedResponse)
      expect(result.data.length).to eq(2)
      expect(result.data.first).to be_a(EasyBroker::Models::Location)
      expect(result.data.first.name).to eq('Test City')
    end

    it 'accepts search parameter' do
      stub_request(:get, "#{base_url}/locations?page=1&limit=20&search=Mexico")
        .to_return(
          status: 200,
          body: response_body.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      locations.list(search: 'Mexico')

      expect(WebMock).to have_requested(:get, "#{base_url}/locations?page=1&limit=20&search=Mexico")
    end

    it 'validates page parameter' do
      expect {
        locations.list(page: -1)
      }.to raise_error(ArgumentError, 'Page must be a positive integer')
    end

    it 'validates limit parameter' do
      expect {
        locations.list(limit: 51)
      }.to raise_error(ArgumentError, 'Limit must be between 1 and 50')
    end
  end

  describe '#search' do
    it 'searches locations with query' do
      stub_request(:get, "#{base_url}/locations?page=1&limit=20&search=Ciudad")
        .to_return(
          status: 200,
          body: {
            'content' => [sample_location_data],
            'pagination' => { 'page' => 1, 'limit' => 20, 'total' => 1 },
            'total' => 1
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      result = locations.search('Ciudad')

      expect(result.data.length).to eq(1)
      expect(WebMock).to have_requested(:get, "#{base_url}/locations")
        .with(query: hash_including('search' => 'Ciudad'))
    end
  end

  describe '#find' do
    it 'returns a single location' do
      stub_request(:get, "#{base_url}/locations/1")
        .to_return(
          status: 200,
          body: sample_location_data.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      result = locations.find(1)

      expect(result).to be_a(EasyBroker::Models::Location)
      expect(result.id).to eq('1')
      expect(result.name).to eq('Test City')
    end

    it 'raises NotFound when location does not exist' do
      stub_request(:get, "#{base_url}/locations/999")
        .to_return(status: 404)

      expect {
        locations.find(999)
      }.to raise_error(EasyBroker::NotFound)
    end
  end
end

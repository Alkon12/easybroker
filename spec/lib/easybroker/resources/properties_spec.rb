require 'rails_helper'

RSpec.describe EasyBroker::Resources::Properties do
  let(:api_key) { 'test_api_key' }
  let(:base_url) { 'https://api.test.com/v1' }
  let(:client) { EasyBroker::Client.new(api_key: api_key, base_url: base_url) }
  let(:properties) { described_class.new(client) }

  before { EasyBroker::RateLimiter.reset! }
  after { EasyBroker::RateLimiter.reset! }

  describe '#list' do
    let(:response_body) do
      {
        'content' => [sample_property_data, sample_property_data.merge('id' => '2')],
        'pagination' => { 'page' => 1, 'limit' => 20, 'total' => 2, 'next_page' => nil },
        'total' => 2
      }
    end

    it 'returns paginated properties' do
      stub_request(:get, "#{base_url}/properties?page=1&limit=20")
        .to_return(
          status: 200,
          body: response_body.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      result = properties.list

      expect(result).to be_a(EasyBroker::Models::PaginatedResponse)
      expect(result.data.length).to eq(2)
      expect(result.data.first).to be_a(EasyBroker::Models::Property)
      expect(result.data.first.title).to eq('Beautiful House in Test City')
      expect(result.pagination.page).to eq(1)
      expect(result.total).to eq(2)
    end

    it 'accepts page and limit parameters' do
      stub_request(:get, "#{base_url}/properties?page=2&limit=10")
        .to_return(
          status: 200,
          body: response_body.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      properties.list(page: 2, limit: 10)

      expect(WebMock).to have_requested(:get, "#{base_url}/properties?page=2&limit=10")
    end

    it 'accepts filters' do
      stub_request(:get, "#{base_url}/properties")
        .with(query: { 'page' => '1', 'limit' => '20', 'search[bedrooms]' => '3' })
        .to_return(
          status: 200,
          body: response_body.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      result = properties.list(filters: { bedrooms: 3 })

      expect(result.data.length).to eq(2)
      expect(WebMock).to have_requested(:get, "#{base_url}/properties")
        .with(query: { 'page' => '1', 'limit' => '20', 'search[bedrooms]' => '3' })
    end

    it 'validates page parameter' do
      expect {
        properties.list(page: 0)
      }.to raise_error(ArgumentError, 'Page must be a positive integer')
    end

    it 'validates limit parameter' do
      expect {
        properties.list(limit: 100)
      }.to raise_error(ArgumentError, 'Limit must be between 1 and 50')
    end
  end

  describe '#find' do
    it 'returns a single property' do
      stub_request(:get, "#{base_url}/properties/1")
        .to_return(
          status: 200,
          body: sample_property_data.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      result = properties.find(1)

      expect(result).to be_a(EasyBroker::Models::Property)
      expect(result.id).to eq('1')
      expect(result.title).to eq('Beautiful House in Test City')
    end

    it 'raises NotFound when property does not exist' do
      stub_request(:get, "#{base_url}/properties/999")
        .to_return(status: 404)

      expect {
        properties.find(999)
      }.to raise_error(EasyBroker::NotFound)
    end
  end

  describe '#search' do
    it 'searches properties with query' do
      stub_request(:get, "#{base_url}/properties")
        .with(query: hash_including('search' => 'house'))
        .to_return(
          status: 200,
          body: {
            'content' => [sample_property_data],
            'pagination' => { 'page' => 1, 'limit' => 20, 'total' => 1 },
            'total' => 1
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      result = properties.search('house')

      expect(result.data.length).to eq(1)
      expect(WebMock).to have_requested(:get, "#{base_url}/properties")
        .with(query: hash_including('search' => 'house'))
    end
  end
end

module EasyBrokerHelper
  def stub_easybroker_request(method, path, response_body: {}, status: 200)
    stub_request(method, "#{ENV.fetch('EASYBROKER_BASE_URL', 'https://api.stagingeb.com')}#{path}")
      .to_return(
        status: status,
        body: response_body.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  def sample_property_data
    {
      'id' => '1',
      'public_id' => 'EB-A1234',
      'title' => 'Beautiful House in Test City',
      'description' => 'A lovely property for testing purposes',
      'property_type' => 'House',
      'operations' => [
        {
          'type' => 'sale',
          'amount' => 1_500_000,
          'formated_amount' => '$1,500,000',
          'currency' => 'USD',
          'unit' => 'total'
        }
      ],
      'bedrooms' => 3,
      'bathrooms' => 2,
      'location' => 'Test City, Test State',
      'show_prices' => true,
      'property_images' => [
        { 'url' => 'https://example.com/image1.jpg', 'title' => 'Image 1' }
      ],
      'updated_at' => '2026-01-01T12:00:00Z'
    }
  end

  def sample_location_data
    {
      'id' => '1',
      'name' => 'Test City',
      'full_name' => 'Test City, Test State, Test Country',
      'type' => 'city',
      'localities' => [
        { 'id' => '2', 'name' => 'Test Neighborhood', 'type' => 'neighborhood' }
      ]
    }
  end

  def sample_paginated_response(data, page: 1, limit: 20, total: nil)
    {
      'content' => data,
      'pagination' => {
        'page' => page,
        'limit' => limit,
        'total' => total || data.length,
        'next_page' => total && ((page * limit) < total) ? page + 1 : nil
      }
    }
  end
end

RSpec.configure do |config|
  config.include EasyBrokerHelper
end

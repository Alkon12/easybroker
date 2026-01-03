require 'rails_helper'

RSpec.describe EasyBroker::Configuration do
  # Store original ENV values and restore after each test
  let(:original_api_key) { ENV['EASYBROKER_API_KEY'] }
  let(:original_base_url) { ENV['EASYBROKER_BASE_URL'] }

  after do
    ENV['EASYBROKER_API_KEY'] = original_api_key
    ENV['EASYBROKER_BASE_URL'] = original_base_url
  end

  describe '#initialize' do
    context 'when no parameters provided' do
      it 'uses environment variables' do
        ENV['EASYBROKER_API_KEY'] = 'test_key'
        ENV['EASYBROKER_BASE_URL'] = 'https://test.api.com'

        config = described_class.new

        expect(config.api_key).to eq('test_key')
        expect(config.base_url).to eq('https://test.api.com')
      end

      it 'uses default base URL when not set in ENV' do
        ENV.delete('EASYBROKER_BASE_URL')

        config = described_class.new

        expect(config.base_url).to eq('https://api.stagingeb.com/v1')
      end
    end

    context 'when parameters are provided' do
      it 'uses provided values over environment variables' do
        ENV['EASYBROKER_API_KEY'] = 'env_key'

        config = described_class.new(
          api_key: 'param_key',
          base_url: 'https://custom.api.com'
        )

        expect(config.api_key).to eq('param_key')
        expect(config.base_url).to eq('https://custom.api.com')
      end
    end
  end

  describe '#valid?' do
    it 'returns true when API key is present' do
      config = described_class.new(api_key: 'test_key')
      expect(config).to be_valid
    end

    it 'returns false when API key is nil' do
      ENV.delete('EASYBROKER_API_KEY')
      config = described_class.new(api_key: nil)
      expect(config).not_to be_valid
    end

    it 'returns false when API key is empty string' do
      ENV.delete('EASYBROKER_API_KEY')
      config = described_class.new(api_key: '')
      expect(config).not_to be_valid
    end
  end

  describe '#validate!' do
    it 'does not raise error when API key is present' do
      config = described_class.new(api_key: 'test_key')
      expect { config.validate! }.not_to raise_error
    end

    it 'raises error when API key is missing' do
      ENV.delete('EASYBROKER_API_KEY')
      config = described_class.new(api_key: nil)
      expect { config.validate! }.to raise_error(EasyBroker::Error, 'API key is required')
    end
  end
end

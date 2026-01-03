require 'rails_helper'

RSpec.describe EasyBroker::Models::Property do
  let(:property_data) { sample_property_data }
  let(:property) { described_class.new(property_data) }

  describe '#initialize' do
    it 'sets basic attributes' do
      expect(property.id).to eq('1')
      expect(property.title).to eq('Beautiful House in Test City')
      expect(property.description).to eq('A lovely property for testing purposes')
      expect(property.property_type).to eq('House')
    end

    it 'parses operations array' do
      expect(property.operations).to eq(['sale'])
    end

    it 'sets numeric attributes' do
      expect(property.bedrooms).to eq(3)
      expect(property.bathrooms).to eq(2)
      expect(property.price).to eq(1_500_000)
    end
  end

  describe '#main_image' do
    it 'returns the first image URL' do
      expect(property.main_image).to eq('https://example.com/image1.jpg')
    end

    it 'returns nil when no images' do
      property_no_images = described_class.new(property_data.merge('property_images' => []))
      expect(property_no_images.main_image).to be_nil
    end
  end

  describe '#formatted_price' do
    it 'formats price with currency symbol' do
      expect(property.formatted_price).to eq('$1,500,000')
    end

    it 'returns "Price on request" when price is nil' do
      property_no_price = described_class.new(property_data.merge('price' => nil))
      expect(property_no_price.formatted_price).to eq('Price on request')
    end
  end

  describe '#for_sale?' do
    it 'returns true when operations include sale' do
      expect(property.for_sale?).to be true
    end

    it 'returns false when operations do not include sale' do
      rental_property = described_class.new(property_data.merge('operations' => ['rental']))
      expect(rental_property.for_sale?).to be false
    end
  end

  describe '#for_rent?' do
    it 'returns false when operations do not include rental' do
      expect(property.for_rent?).to be false
    end

    it 'returns true when operations include rental' do
      rental_property = described_class.new(property_data.merge('operations' => ['rental']))
      expect(rental_property.for_rent?).to be true
    end
  end

  describe '#operation_types' do
    it 'returns operation types as human-readable string' do
      expect(property.operation_types).to eq('For Sale')
    end

    it 'combines multiple operations' do
      both_property = described_class.new(property_data.merge('operations' => ['sale', 'rental']))
      expect(both_property.operation_types).to eq('For Sale / For Rent')
    end
  end

  describe '#summary' do
    it 'returns property summary' do
      expect(property.summary).to eq('3 bed • 2 bath')
    end

    it 'includes parking when available' do
      with_parking = described_class.new(property_data.merge('parking_spaces' => 2))
      expect(with_parking.summary).to eq('3 bed • 2 bath • 2 parking')
    end
  end

  describe '#full_location' do
    it 'returns location string' do
      expect(property.full_location).to eq('Test City, Test State')
    end
  end

  describe '#to_h' do
    it 'converts property to hash' do
      hash = property.to_h
      expect(hash).to be_a(Hash)
      expect(hash[:title]).to eq('Beautiful House in Test City')
      expect(hash[:bedrooms]).to eq(3)
    end
  end
end

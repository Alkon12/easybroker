require 'rails_helper'

RSpec.describe EasyBroker::Models::Location do
  let(:location_data) { sample_location_data }
  let(:location) { described_class.new(location_data) }

  describe '#initialize' do
    it 'sets basic attributes' do
      expect(location.id).to eq('1')
      expect(location.name).to eq('Test City')
      expect(location.full_name).to eq('Test City, Test State, Test Country')
      expect(location.type).to eq('city')
    end

    it 'initializes localities as Location objects' do
      expect(location.localities).to be_an(Array)
      expect(location.localities.first).to be_a(described_class)
      expect(location.localities.first.name).to eq('Test Neighborhood')
    end
  end

  describe '#has_localities?' do
    it 'returns true when location has localities' do
      expect(location.has_localities?).to be true
    end

    it 'returns false when location has no localities' do
      no_localities = described_class.new(location_data.merge('localities' => []))
      expect(no_localities.has_localities?).to be false
    end
  end

  describe '#localities_count' do
    it 'returns the number of localities' do
      expect(location.localities_count).to eq(1)
    end
  end

  describe '#city?' do
    it 'returns true for city type' do
      expect(location.city?).to be true
    end

    it 'returns false for non-city types' do
      state = described_class.new(location_data.merge('type' => 'state'))
      expect(state.city?).to be false
    end
  end

  describe '#state?' do
    it 'returns true for state type' do
      state = described_class.new(location_data.merge('type' => 'state'))
      expect(state.state?).to be true
    end

    it 'returns true for province type' do
      province = described_class.new(location_data.merge('type' => 'province'))
      expect(province.state?).to be true
    end
  end

  describe '#neighborhood?' do
    it 'returns true for neighborhood type' do
      neighborhood = described_class.new(location_data.merge('type' => 'neighborhood'))
      expect(neighborhood.neighborhood?).to be true
    end

    it 'returns true for colonia type' do
      colonia = described_class.new(location_data.merge('type' => 'colonia'))
      expect(colonia.neighborhood?).to be true
    end
  end

  describe '#type_label' do
    it 'returns human-readable type for city' do
      expect(location.type_label).to eq('City')
    end

    it 'returns human-readable type for state' do
      state = described_class.new(location_data.merge('type' => 'state'))
      expect(state.type_label).to eq('State')
    end

    it 'returns Unknown for nil type' do
      no_type = described_class.new(location_data.merge('type' => nil))
      expect(no_type.type_label).to eq('Unknown')
    end
  end

  describe '#display_name' do
    it 'returns full_name when available' do
      expect(location.display_name).to eq('Test City, Test State, Test Country')
    end

    it 'falls back to name when full_name is nil' do
      no_full_name = described_class.new(location_data.merge('full_name' => nil))
      expect(no_full_name.display_name).to eq('Test City')
    end
  end

  describe '#to_h' do
    it 'converts location to hash' do
      hash = location.to_h
      expect(hash).to be_a(Hash)
      expect(hash[:name]).to eq('Test City')
      expect(hash[:type]).to eq('city')
      expect(hash[:localities_count]).to eq(1)
    end
  end

  describe '#all_localities' do
    it 'flattens all nested localities' do
      nested_data = {
        'id' => '1',
        'name' => 'Country',
        'type' => 'country',
        'localities' => [
          {
            'id' => '2',
            'name' => 'State',
            'type' => 'state',
            'localities' => [
              { 'id' => '3', 'name' => 'City', 'type' => 'city', 'localities' => [] }
            ]
          }
        ]
      }

      country = described_class.new(nested_data)
      all = country.all_localities

      expect(all.length).to eq(2) # State + City
      expect(all.map(&:name)).to contain_exactly('State', 'City')
    end
  end
end

require 'rails_helper'

RSpec.describe EasyBroker::Models::Pagination do
  describe '#initialize' do
    it 'sets attributes from data' do
      pagination = described_class.new({
        'page' => 2,
        'limit' => 20,
        'total' => 100,
        'next_page' => 3
      })

      expect(pagination.page).to eq(2)
      expect(pagination.limit).to eq(20)
      expect(pagination.total).to eq(100)
      expect(pagination.next_page).to eq(3)
    end

    it 'uses defaults when data is empty' do
      pagination = described_class.new({})

      expect(pagination.page).to eq(1)
      expect(pagination.limit).to eq(20)
      expect(pagination.total).to eq(0)
      expect(pagination.next_page).to be_nil
    end
  end

  describe '#next_page?' do
    it 'returns true when next_page is present' do
      pagination = described_class.new({ 'next_page' => 2 })
      expect(pagination.next_page?).to be true
    end

    it 'returns false when next_page is nil' do
      pagination = described_class.new({ 'next_page' => nil })
      expect(pagination.next_page?).to be false
    end
  end

  describe '#next_page_number' do
    it 'returns nil when next_page is nil' do
      pagination = described_class.new({ 'next_page' => nil })
      expect(pagination.next_page_number).to be_nil
    end

    it 'returns the number when next_page is already an integer' do
      pagination = described_class.new({ 'next_page' => 3 })
      expect(pagination.next_page_number).to eq(3)
    end

    it 'extracts page number from URL with query string' do
      pagination = described_class.new({
        'next_page' => 'https://api.stagingeb.com/v1/properties?limit=20&page=2'
      })
      expect(pagination.next_page_number).to eq(2)
    end

    it 'extracts page number from URL with page as first parameter' do
      pagination = described_class.new({
        'next_page' => 'https://api.stagingeb.com/v1/properties?page=5&limit=20'
      })
      expect(pagination.next_page_number).to eq(5)
    end

    it 'returns nil when URL has no page parameter' do
      pagination = described_class.new({
        'next_page' => 'https://api.stagingeb.com/v1/properties?limit=20'
      })
      expect(pagination.next_page_number).to be_nil
    end
  end

  describe '#total_pages' do
    it 'calculates total pages correctly' do
      pagination = described_class.new({ 'total' => 100, 'limit' => 20 })
      expect(pagination.total_pages).to eq(5)
    end

    it 'rounds up for partial pages' do
      pagination = described_class.new({ 'total' => 95, 'limit' => 20 })
      expect(pagination.total_pages).to eq(5)
    end

    it 'returns 0 when total is zero' do
      pagination = described_class.new({ 'total' => 0, 'limit' => 20 })
      expect(pagination.total_pages).to eq(0)
    end
  end

  describe '#first_page?' do
    it 'returns true on page 1' do
      pagination = described_class.new({ 'page' => 1 })
      expect(pagination.first_page?).to be true
    end

    it 'returns false on other pages' do
      pagination = described_class.new({ 'page' => 2 })
      expect(pagination.first_page?).to be false
    end
  end

  describe '#last_page?' do
    it 'returns true when no next_page' do
      pagination = described_class.new({ 'next_page' => nil })
      expect(pagination.last_page?).to be true
    end

    it 'returns false when next_page exists' do
      pagination = described_class.new({ 'next_page' => 3 })
      expect(pagination.last_page?).to be false
    end
  end

  describe '#to_h' do
    it 'converts to hash' do
      pagination = described_class.new({ 'page' => 1, 'limit' => 20, 'total' => 50, 'next_page' => 2 })
      hash = pagination.to_h

      expect(hash).to include(
        page: 1,
        limit: 20,
        total: 50,
        next_page: 2,
        total_pages: 3
      )
    end
  end
end

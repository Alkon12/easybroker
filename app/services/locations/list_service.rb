module Locations
  # Service to list locations from EasyBroker API
  class ListService
    DEFAULT_LIMIT = 20

    def initialize(search: nil, page: 1, limit: DEFAULT_LIMIT)
      @search = search
      @page = [page.to_i, 1].max
      @limit = [[limit.to_i, 1].max, 50].min
    end

    def call
      client = easybroker_client
      result = client.locations.list(
        search: @search,
        page: @page,
        limit: @limit
      )

      {
        locations: result.data,
        pagination: result.pagination,
        total: result.total,
        success: true
      }
    rescue EasyBroker::Error => e
      {
        locations: [],
        pagination: nil,
        total: 0,
        success: false,
        error: e.message
      }
    end

    private

    def easybroker_client
      @client ||= EasyBroker::Client.new
    end
  end
end

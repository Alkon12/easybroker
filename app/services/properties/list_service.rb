module Properties
  # Service to list properties from EasyBroker API
  class ListService
    DEFAULT_LIMIT = 20

    def initialize(page: 1, limit: DEFAULT_LIMIT, filters: {})
      @page = [page.to_i, 1].max
      @limit = [[limit.to_i, 1].max, 50].min
      @filters = filters
    end

    def call
      client = easybroker_client
      result = client.properties.list(
        page: @page,
        limit: @limit,
        filters: sanitized_filters
      )

      {
        properties: result.data,
        pagination: result.pagination,
        total: result.total,
        success: true
      }
    rescue EasyBroker::Error => e
      {
        properties: [],
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

    def sanitized_filters
      return {} if @filters.blank?

      allowed = {}

      # Search query
      allowed[:search] = @filters[:search] if @filters[:search].present?

      # Numeric filters
      %i[bedrooms bathrooms parking_spaces min_price max_price].each do |key|
        allowed[key] = @filters[key].to_i if @filters[key].present?
      end

      # Array filters
      if @filters[:property_types].present?
        allowed[:property_types] = Array(@filters[:property_types]).reject(&:blank?)
      end

      if @filters[:statuses].present?
        allowed[:statuses] = Array(@filters[:statuses]).reject(&:blank?)
      end

      allowed
    end
  end
end

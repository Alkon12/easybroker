class LocationsController < ApplicationController
  include ErrorHandling

  # GET /locations
  def index
    @search = params[:search]
    @page = params[:page]&.to_i || 1
    @limit = params[:limit]&.to_i || 20

    result = Locations::ListService.new(
      search: @search,
      page: @page,
      limit: @limit
    ).call

    if result[:success]
      @locations = result[:locations]
      @pagination = result[:pagination]
      @total = result[:total]
    else
      flash.now[:alert] = result[:error]
      @locations = []
      @pagination = nil
      @total = 0
    end
  end

  # GET /locations/map_properties.json
  # Returns property data for map visualization
  def map_properties
    result = Properties::MapDataService.new.call

    # Set cache headers to prevent excessive API calls from browser
    # Cache for 10 minutes to match service cache TTL
    expires_in 10.minutes, public: true

    respond_to do |format|
      format.json do
        if result[:success]
          render json: {
            properties: result[:properties],
            meta: {
              total_fetched: result[:total_fetched],
              valid_count: result[:valid_count]
            }
          }
        else
          render json: { error: result[:error] }, status: :unprocessable_entity
        end
      end
    end
  end
end

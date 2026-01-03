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
end

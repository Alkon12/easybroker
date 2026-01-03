class PropertiesController < ApplicationController
  include ErrorHandling

  # GET /properties
  def index
    @page = params[:page]&.to_i || 1
    @limit = params[:limit]&.to_i || 20

    result = Properties::ListService.new(
      page: @page,
      limit: @limit,
      filters: filter_params
    ).call

    if result[:success]
      @properties = result[:properties]
      @pagination = result[:pagination]
      @total = result[:total]
    else
      flash.now[:alert] = result[:error]
      @properties = []
      @pagination = nil
      @total = 0
    end
  end

  # GET /properties/:id
  def show
    result = Properties::DetailsService.new(params[:id]).call

    if result[:success]
      @property = result[:property]
    else
      flash[:alert] = result[:error]
      redirect_to properties_path
    end
  end

  private

  def filter_params
    params.permit(
      :search,
      :bedrooms,
      :bathrooms,
      :parking_spaces,
      :min_price,
      :max_price,
      property_types: [],
      statuses: []
    ).to_h
  end
end

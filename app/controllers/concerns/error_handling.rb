module ErrorHandling
  extend ActiveSupport::Concern

  included do
    rescue_from EasyBroker::Error, with: :handle_api_error
  end

  private

  def handle_api_error(exception)
    case exception
    when EasyBroker::Unauthorized
      flash[:alert] = 'API authentication failed. Please check your API credentials.'
      redirect_to root_path, status: :unauthorized
    when EasyBroker::NotFound
      flash[:alert] = 'The requested resource was not found.'
      redirect_to root_path, status: :not_found
    when EasyBroker::RateLimitExceeded
      flash[:alert] = 'Too many requests. Please try again in a moment.'
      redirect_back(fallback_location: root_path, status: :too_many_requests)
    else
      flash[:alert] = "An error occurred: #{exception.message}"
      redirect_back(fallback_location: root_path, status: :service_unavailable)
    end
  end
end

module ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from StandardError, with: :handle_standard_error
    rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
  end

  private

  def handle_standard_error(exception)
    logger.error "StandardError caught: #{exception.message}\nBacktrace:\n#{exception.backtrace.join("\n")}"
    respond_to do |format|
      format.html { render template: 'errors/general', status: 500 }
      format.json { render json: { error: 'Internal Server Error', message: exception.message }, status: 500 }
    end
  end

  def handle_not_found(exception)
    logger.warn "RecordNotFound caught: #{exception.message}"
    respond_to do |format|
      format.html { render template: 'errors/not_found', status: 404 }
      format.json { render json: { error: 'Not Found', message: exception.message }, status: 404 }
    end
  end
end

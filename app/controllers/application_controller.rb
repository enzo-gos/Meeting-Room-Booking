class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  protect_from_forgery
  include Pundit

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  include Pagy::Backend

  private

  def user_not_authorized(exception)
    policy_name = exception.policy.class.to_s.underscore

    flash[:error] = t "#{policy_name}.#{exception.query}", scope: 'pundit', default: :default
    redirect_to dashboard_path
  end
end

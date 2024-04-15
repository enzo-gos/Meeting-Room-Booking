class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    add_breadcrumb 'Dashboard', dashboard_path

    @user = current_user
  end
end

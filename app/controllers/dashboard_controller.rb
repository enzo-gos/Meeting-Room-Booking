class DashboardController < ApplicationController
  def index
    add_breadcrumb 'Dashboard', dashboard_path
    @user = current_user
  end
end

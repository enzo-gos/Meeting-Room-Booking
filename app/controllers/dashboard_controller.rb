class DashboardController < ApplicationController
  before_action :authenticate_user!
  # add_breadcrumb 'Dashboard', '/'

  def index
    add_breadcrumb 'Dashboard', '/'

    @user = current_user
  end
end

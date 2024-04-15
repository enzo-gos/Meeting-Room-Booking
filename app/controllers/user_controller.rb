class UserController < ApplicationController
  def profile
    add_breadcrumb 'User Profile', user_profile_path
    @user_profile = current_user
  end
end

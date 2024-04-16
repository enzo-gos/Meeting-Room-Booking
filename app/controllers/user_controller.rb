class UserController < ApplicationController
  before_action :authenticate_user!

  def index
    add_breadcrumb 'User Profile', user_profile_path
    @user_profile = current_user
  end

  def update
    @user_profile = current_user
    if @user_profile.update(user_profile_params)
      render :index, notice: 'Profile updated successfully.', status: :created
    else
      @user_profile.errors.add(:current_password, 'is incorrect')
      render :index, status: :unprocessable_entity
    end
  end

  private

  def user_profile_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end
end

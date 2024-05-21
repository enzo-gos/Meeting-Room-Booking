class UsersController < ApplicationController
  add_breadcrumb 'User Profile', :profile_users_path

  def index
    @user_profile = current_user
  end

  def update
    @user_profile = current_user
    if @user_profile.update(user_profile_params)
      bypass_sign_in @user_profile

      flash.now[:notice] = 'Profile updated successfully.'

      render :index, status: :created
    else
      @user_profile.errors.add(:current_password, 'is incorrect')
      render :index, status: :unprocessable_entity
    end
  end

  private

  def user_profile_params
    params.require(:user).permit(:avatar, :current_password, :password, :password_confirmation)
  end
end

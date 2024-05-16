class Admin::UserManagementController < ApplicationController
  before_action :init_breadcrumbs
  before_action :init_employees, only: [:index]

  def index; end

  def new
    @employee = User.new
  end

  def create
    @employee = User.create(employee_params.merge({ password: Devise.friendly_token[0, 20] }))
    if @employee.save
      redirect_to admin_user_management_index_path, notice: 'Employee was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    add_breadcrumb 'Edit'
    @employee = User.find(params[:id])
  end

  def update
    add_breadcrumb 'Edit'
    @employee = User.find(params[:id])

    if @employee.update(employee_params)
      redirect_to admin_user_management_index_path, notice: 'Employee was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @employee = User.find(params[:id])
    @employee.destroy
    redirect_to admin_user_management_index_path, notice: 'Employee was successfully deleted.'
  end

  private

  def init_breadcrumbs
    add_breadcrumb 'Manage'
  end

  def init_employees
    @employees = User.all
  end

  def employee_params
    params.require(:user).permit(:email, :role_ids, :team_ids)
  end
end

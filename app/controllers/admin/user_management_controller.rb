class Admin::UserManagementController < ApplicationController
  before_action :init_breadcrumbs
  before_action :init_update_breadcrumb, only: [:edit, :update]
  before_action :init_employees, only: [:index]
  before_action :init_employee, except: [:create, :new, :index]

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

  def edit; end

  def update
    if @employee.update(employee_params)
      redirect_to admin_user_management_index_path, notice: 'Employee was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @employee.destroy
    redirect_to admin_user_management_index_path, notice: 'Employee was successfully deleted.'
  end

  private

  def init_breadcrumbs
    add_breadcrumb 'Manage'
    add_breadcrumb 'Users'
  end

  def init_update_breadcrumb
    add_breadcrumb 'Edit'
  end

  def init_employees
    @employees = User.all
  end

  def init_employee
    @employee = User.find(params[:id])
  end

  def employee_params
    params.require(:user).permit(:email, :role_ids, :team_ids)
  end
end

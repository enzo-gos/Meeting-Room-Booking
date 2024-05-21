class Admin::UsersController < ApplicationController
  before_action :init_breadcrumbs
  before_action :init_update_breadcrumb, only: [:edit, :update]
  before_action :prepare_employee_list, only: [:index]
  before_action :prepare_employee, except: [:create, :new, :index]

  def index; end

  def new
    @employee = User.new
  end

  def create
    @employee = User.create(employee_params.merge({ password: User.default_password }))
    if @employee.save
      redirect_to admin_users_path, notice: 'Employee was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @employee.update(employee_params)
      redirect_to admin_users_path, notice: 'Employee was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @employee.destroy
    redirect_to admin_users_path, notice: 'Employee was successfully deleted.'
  end

  private

  def init_breadcrumbs
    add_breadcrumb 'Manage'
    add_breadcrumb 'Users'
  end

  def init_update_breadcrumb
    add_breadcrumb 'Edit'
  end

  def prepare_employee_list
    @employees = User.includes([:teams, :roles]).all
  end

  def prepare_employee
    @employee = User.find(params[:id])
  end

  def employee_params
    params.require(:user).permit(:email, :role_ids, :team_ids)
  end
end

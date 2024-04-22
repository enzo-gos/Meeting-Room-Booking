class Admin::MeetingRoomManagementController < ApplicationController
  before_action :authenticate_user!
  before_action :role_admin?

  add_breadcrumb 'Manage'
  add_breadcrumb 'Rooms'

  def index
    @meeting_rooms = Room.all
    @facilities = Facility.all
  end

  def create
    @meeting_room = Room.new(room_params)
    if @meeting_room.save
      redirect_to admin_meeting_room_management_index_path, notice: 'Meeting room was successfully created.'
    else
      @facilities = Facility.all
      render :new, status: :unprocessable_entity
    end
  end

  def new
    add_breadcrumb 'Create', new_admin_meeting_room_management_path
    @meeting_room = Room.new
  end

  def edit
    add_breadcrumb params[:id], edit_admin_meeting_room_management_path
    add_breadcrumb 'Edit', edit_admin_meeting_room_management_path

    @meeting_room = Room.find(params[:id])
  end

  def update
    @meeting_room = Room.find(params[:id])

    if @meeting_room.update(room_params)
      redirect_to edit_admin_meeting_room_management_path, notice: 'Meeting room was successfully updated.'
    else
      flash.now[:alert] = "Error updating meeting room: #{params.inspect}"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @meeting_room = Room.find(params[:id])
    @meeting_room.destroy
    redirect_to admin_meeting_room_management_index_path, notice: 'Meeting room was successfully destroyed.'
  end

  private

  def room_params
    params[:room][:facility_ids] = params[:room][:facility_ids].split(',').map(&:strip) || []
    params.required(:room).permit(:name, :max_capacity, :department_id, :description, :preview_image, facility_ids: [])
  end

  def role_admin?
    redirect_to authenticated_root_path unless current_user.has_role?(:admin)
  end
end

class Admin::MeetingRoomManagementController < ApplicationController
  before_action :init_breadcrumbs

  before_action :prepare_meeting_rooms, only: [:index]
  before_action :prepare_meeting_room, only: [:edit, :update, :destroy]

  def index; end

  def new
    add_breadcrumb 'Create', new_admin_meeting_room_management_path
    @meeting_room = Room.new
  end

  def create
    @meeting_room = Room.new(room_params)
    authorize @meeting_room, policy_class: RoomManagementPolicy

    if @meeting_room.save
      redirect_to admin_meeting_room_management_index_path, notice: 'Meeting room was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    add_breadcrumb params[:id], edit_admin_meeting_room_management_path
    add_breadcrumb 'Edit', edit_admin_meeting_room_management_path
  end

  def update
    if @meeting_room.update(room_params)
      redirect_to edit_admin_meeting_room_management_path, notice: 'Meeting room was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @meeting_room.destroy
    redirect_to admin_meeting_room_management_index_path, notice: 'Meeting room was successfully destroyed.'
  end

  private

  def room_params
    params[:room][:facility_ids] = params[:room][:facility_ids].split(',').map(&:strip) || []
    params.required(:room).permit(:name, :max_capacity, :department_id, :description, :preview_image, facility_ids: [])
  end

  def prepare_meeting_rooms
    @facilities = Facility.all
    @meeting_rooms = policy_scope(Room, policy_scope_class: RoomManagementPolicy::Scope).order(:id)

    @pagination, @meeting_rooms = pagy(@meeting_rooms)

    authorize @meeting_rooms, policy_class: RoomManagementPolicy
  end

  def prepare_meeting_room
    @meeting_room = Room.find(params[:id])
    authorize @meeting_room, policy_class: RoomManagementPolicy
  end

  def init_breadcrumbs
    add_breadcrumb 'Manage'
    add_breadcrumb 'Rooms'
  end
end

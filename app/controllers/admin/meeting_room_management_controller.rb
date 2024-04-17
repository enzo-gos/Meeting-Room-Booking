class Admin::MeetingRoomManagementController < ApplicationController
  before_action :authenticate_user!

  add_breadcrumb 'Manage'
  add_breadcrumb 'Rooms'

  def index
    @meeting_rooms = Room.all
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

    @facilities = Facility.all
    @meeting_room = Room.new
  end

  def room_params
    params[:room][:facility_ids] = params[:room][:facility_ids].split(',').map(&:strip) if params[:room][:facility_ids].present? && !params[:room][:facility_ids].empty? && !params[:room][:facility_ids].nil?
    params.required(:room).permit(:name, :max_capacity, :department_id, :description, :preview_image, facility_ids: [])
  end
end

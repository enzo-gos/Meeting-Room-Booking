class MeetingRoomsController < ApplicationController
  include Filterable

  before_action :init_breadcrumbs

  def index
    @filter_history, @departments_rooms = filter!(Room)
    @departments_rooms = @departments_rooms.group_by(&:department)
  end

  private

  def init_breadcrumbs
    add_breadcrumb 'Meeting Rooms'
  end
end

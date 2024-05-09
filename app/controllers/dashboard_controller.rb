class DashboardController < ApplicationController
  include Filterable

  def index
    add_breadcrumb 'Dashboard', dashboard_path

    @rooms = Room.includes(:department).where(id: MeetingReservation.where(book_by_id: current_user.id).pluck(:room_id)).distinct
    @rooms = @rooms.map { |room| { name: "#{room.name} - #{room.department.name}", id: room.id } }

    @filter_history, @reservations = filter!(MeetingReservation)

    @pagination, @reservations = pagy(@reservations)
  end
end

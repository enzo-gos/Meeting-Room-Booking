class DashboardController < ApplicationController
  include Filterable

  def index
    add_breadcrumb 'Dashboard', dashboard_path

    @rooms = Room.includes(:department).where(id: MeetingReservation.where(book_by_id: current_user.id).pluck(:room_id)).distinct
    @rooms = @rooms.map { |room| { name: "#{room.name} - #{room.department.name}", id: room.id } }

    @filter_history, @reservations = filter!(MeetingReservation)

    @reservations = @reservations.by_book_by(current_user.id).by_schedule

    @pagination, @reservations = pagy(@reservations)

    @reservations_history = MeetingReservation.by_history
    @pagination_history, @reservations_history = pagy(@reservations_history)
  end
end

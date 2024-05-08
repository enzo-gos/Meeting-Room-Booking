class ReservationController < ApplicationController
  before_action :init_breadcrumbs
  before_action :init_reservation

  def edit
    add_breadcrumb 'Edit'

    @user_list = User.where.not(id: current_user.id)

    @selected_rule = @meeting_reservation.rule_to_option
  end

  def show
    add_breadcrumb params[:id]

    @meeting_room = @meeting_reservation.room
    @members = @meeting_reservation.members

    @selected_rule = @meeting_reservation.rule_to_option
  end

  private

  def init_breadcrumbs
    add_breadcrumb 'Reservation'
    add_breadcrumb params[:id]
  end

  def init_reservation
    @meeting_reservation = MeetingReservation.find(params[:id])
  end
end

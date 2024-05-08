class ReservationController < ApplicationController
  before_action :init_breadcrumbs

  def edit
    add_breadcrumb params[:id]
    add_breadcrumb 'Edit'

    @meeting_reservation = MeetingReservation.find(params[:id])
    @user_list = User.where.not(id: current_user.id)

    @selected_rule = @meeting_reservation.rule_to_option
  end

  def show
    add_breadcrumb params[:id]

    @meeting_reservation = MeetingReservation.find(params[:id])
    @meeting_room = @meeting_reservation.room
    @members = @meeting_reservation.members
    @user_list = User.where.not(id: current_user.id)

    @selected_rule = @meeting_reservation.rule_to_option
  end

  private

  def init_breadcrumbs
    add_breadcrumb 'Reservation'
  end
end

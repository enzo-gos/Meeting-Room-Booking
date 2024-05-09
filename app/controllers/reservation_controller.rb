class ReservationController < ApplicationController
  include GoogleCalendar

  before_action :init_breadcrumbs
  before_action :init_reservation
  before_action :authorize_reservation, only: [:edit, :update]
  before_action :init_userlist, only: [:edit, :update]

  def edit
    add_breadcrumb 'Edit'

    authorize @meeting_reservation, policy_class: ReservationPolicy

    @selected_rule = @meeting_reservation.rule_to_option
  end

  def update
    respond_to do |format|
      if @meeting_reservation.update(reservation_params)

        begin
          start_date_time = @meeting_reservation.start_datetime_with_recurring.strftime('%Y-%m-%dT%H:%M:%S%:z')
          end_date_time = @meeting_reservation.end_datetime_with_recurring.strftime('%Y-%m-%dT%H:%M:%S%:z')

          update_event(
            event_id: @meeting_reservation.calendar_event,
            title: @meeting_reservation.title,
            start_date: start_date_time,
            end_date: end_date_time,
            members: @meeting_reservation.allmembers,
            note: @meeting_reservation.note.body.to_s,
            recurrence: @meeting_reservation.recurring.empty? ? [] : [@meeting_reservation.google_calendar_rule]
          )
        rescue Google::Apis::AuthorizationError => _e
          client = initialize_client
          response = client.refresh!
          session[:authorization] = session[:authorization].merge(response)
          retry
        end

        SendEventJob.perform_async(@meeting_reservation.to_json)

        format.html { redirect_to details_meeting_room_path(@meeting_reservation.room_id), notice: 'Meeting reservation was successfully updated.' }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.update('modal-body', partial: 'reservation/shared/edit_form', locals: { data_controller: 'flatpickr' }), status: :unprocessable_entity }
      end
    end
  end

  def show
    add_breadcrumb params[:id]

    @meeting_room = @meeting_reservation.room
    @members = @meeting_reservation.members

    @selected_rule = @meeting_reservation.rule_to_option
  end

  def destroy
    room_id = @meeting_reservation.room_id
    @meeting_reservation.destroy

    begin
      delete_event(event_id: @meeting_reservation.calendar_event)
    rescue Google::Apis::AuthorizationError => _e
      client = initialize_client
      response = client.refresh!
      session[:authorization] = session[:authorization].merge(response)
      retry
    end

    redirect_to details_meeting_room_path(room_id), notice: 'Meeting reservation was successfully destroyed.'
  end

  private

  def init_breadcrumbs
    add_breadcrumb 'Reservation'
    add_breadcrumb params[:id]
  end

  def init_reservation
    @meeting_reservation = MeetingReservation.find(params[:id])
  end

  def authorize_reservation
    authorize @meeting_reservation, policy_class: ReservationPolicy
  end

  def reservation_params
    params[:meeting_reservation][:member_ids] = params[:meeting_reservation][:member_ids].split(',').map(&:strip) || []
    params.require(:meeting_reservation).permit(:title, :note, :recurring, :book_at, :start_time, :end_time, :team_id, member_ids: [])
  end

  def init_userlist
    @user_list = User.where.not(id: current_user.id)
  end
end

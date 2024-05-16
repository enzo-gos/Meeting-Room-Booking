class ReservationController < ApplicationController
  include GoogleCalendar

  before_action :init_breadcrumbs
  before_action :init_reservation
  before_action :authorize_reservation, except: [:show]
  before_action :init_userlist, only: [:edit, :update]
  before_action :validate_recurring, only: [:show, :edit, :update]
  add_breadcrumb 'Edit', only: [:edit, :update]

  def edit
    @selected_rule = @meeting_reservation.rule_to_option
  end

  def update
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
          recurrence: @meeting_reservation.recurring? ? [@meeting_reservation.google_calendar_rule] : []
        )

        @meeting_reservation.perform_to_update_history
      rescue Google::Apis::AuthorizationError => _e
        client = initialize_client
        response = client.refresh!
        session[:authorization] = session[:authorization].merge(response)
        retry
      end

      redirect_to details_meeting_room_path(@meeting_reservation.room_id), notice: 'Meeting reservation was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def show
    add_breadcrumb params[:id]

    @meeting_room = @meeting_reservation.room
    @members = @meeting_reservation.members

    @selected_rule = @meeting_reservation.rule_to_option
  end

  def destroy
    if !@meeting_reservation.recurring? || (@meeting_reservation.recurring? && params[:delete_option] == '0')
      delete_all
      redirect_to details_meeting_room_path(@meeting_reservation.room_id), notice: 'Meeting reservation was successfully destroyed.'
    elsif params[:delete_option] == '1'
      delete_only
      redirect_to details_meeting_room_path(@meeting_reservation.room_id), notice: 'Meeting reservation was successfully destroyed.'
    else
      render turbo_stream: turbo_stream.update('modal-body', partial: 'reservation/shared/delete_options', locals: { meeting_reservation: @meeting_reservation })
    end
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
    current_book_at = @meeting_reservation.book_at.strftime('%Y-%m-%d')
    params[:meeting_reservation][:book_at] = params[:origin_book_at] if params[:current_recurring_date] == current_book_at

    params[:meeting_reservation][:member_ids] = params[:meeting_reservation][:member_ids].split(',').map(&:strip) || []
    params.require(:meeting_reservation).permit(:title, :note, :recurring, :book_at, :start_time, :end_time, :team_id, member_ids: [])
  end

  def init_userlist
    @user_list = User.where.not(id: current_user.id)
  end

  def validate_recurring
    if @meeting_reservation.recurring? && (!params[:recurring] || !@meeting_reservation.occurrence?(Time.at(params[:recurring].to_i).to_date))
      redirect_to details_meeting_room_path(@meeting_reservation.room_id)
    end

    params[:origin_book_at] = @meeting_reservation.book_at.strftime('%Y-%m-%d')

    if @meeting_reservation.recurring?
      params[:current_recurring_date] = Time.at(params[:recurring].to_i).to_date.strftime('%Y-%m-%d')
      @meeting_reservation.book_at = params[:current_recurring_date]
    end
  end

  def delete_all
    @meeting_reservation.destroy
    begin
      delete_event(event_id: @meeting_reservation.calendar_event)
    rescue Google::Apis::AuthorizationError => _e
      client = initialize_client
      response = client.refresh!
      session[:authorization] = session[:authorization].merge(response)
      retry
    end
  end

  def delete_only
    extimes = @meeting_reservation.extimes + @meeting_reservation.except_date(params[:except_date])

    @meeting_reservation.update(extimes: extimes)

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
        recurrence: @meeting_reservation.recurring? ? [@meeting_reservation.google_calendar_rule] : []
      )
    rescue Google::Apis::AuthorizationError => _e
      client = initialize_client
      response = client.refresh!
      session[:authorization] = session[:authorization].merge(response)
      retry
    end
  end
end

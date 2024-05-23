class ReservationsController < ApplicationController
  include ReservationsHelper

  before_action :init_breadcrumbs
  before_action :prepared_reservation
  before_action :authorize_reservation, except: [:show]
  before_action :prepared_update_data, only: [:edit, :update]
  before_action :prepared_recurring_rules, only: [:show, :edit, :update]
  before_action :validate_recurring, only: [:show, :edit, :update]

  add_breadcrumb 'Edit', only: [:edit, :update]

  def edit; end

  def update
    event = @meeting_reservation.to_calendar_event if @meeting_reservation.update(reservation_params)

    begin
      google_event = GoogleCalendarManager::Updater.new(authorization: session[:authorization], event: event).call if event.present?
    rescue Google::Apis::AuthorizationError => _e
      client, _service = GoogleCalendarManager::Initializer.new(session[:authorization]).call
      session[:authorization] = session[:authorization].merge(client.refresh!)
      retry
    end

    if google_event.present?
      redirect_to details_meeting_room_path(@meeting_reservation.room_id), notice: 'Meeting reservation was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def show
    @meeting_room = @meeting_reservation.room
    @members = @meeting_reservation.members
    @selected_rule = option_from_rule(@meeting_reservation)
  end

  def destroy
    deleted = false
    deleted = delete_all if !@meeting_reservation.recurring? || (@meeting_reservation.recurring? && params[:delete_option] == '0')
    deleted = delete_only if @meeting_reservation.recurring? && params[:delete_option] == '1'

    return redirect_to details_meeting_room_path(@meeting_reservation.room_id), notice: 'Meeting reservation was successfully destroyed.' if deleted

    render turbo_stream: turbo_stream.update('modal-body', partial: 'reservations/shared/delete_options', locals: { meeting_reservation: @meeting_reservation })
  end

  private

  def init_breadcrumbs
    add_breadcrumb 'Reservation'
    add_breadcrumb params[:id]
  end

  def prepared_reservation
    @meeting_reservation = MeetingReservation.find(params[:id])
  end

  def prepared_recurring_rules
    @selected_rule = option_from_rule(@meeting_reservation)
  end

  def authorize_reservation
    authorize @meeting_reservation, policy_class: ReservationPolicy
  end

  def reservation_params
    params[:meeting_reservation][:member_ids] = params[:meeting_reservation][:member_ids].split(',').map(&:strip)
    params.require(:meeting_reservation).permit(:title, :note, :recurring, :book_at, :start_time, :end_time, :team_id, member_ids: [])
  end

  def prepared_update_data
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
    reservation = @meeting_reservation.destroy
    begin
      GoogleCalendarManager::Destroyer.new(authorization: session[:authorization], event: @meeting_reservation.to_calendar_event).call
    rescue Google::Apis::AuthorizationError => _e
      client, _service = GoogleCalendarManager::Initializer.new(session[:authorization]).call
      session[:authorization] = session[:authorization].merge(client.refresh!)
      retry
    end
    reservation.destroyed?
  end

  def delete_only
    extimes = @meeting_reservation.extimes + @meeting_reservation.except_date(params[:except_date])
    updated = @meeting_reservation.update(extimes: extimes)

    begin
      google_event = GoogleCalendarManager::Updater.new(authorization: session[:authorization], event: @meeting_reservation.to_calendar_event).call if updated
    rescue Google::Apis::AuthorizationError => _e
      client, _service = GoogleCalendarManager::Initializer.new(session[:authorization]).call
      session[:authorization] = session[:authorization].merge(client.refresh!)
      retry
    end
    google_event.present?
  end
end

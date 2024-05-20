class MeetingRoomsController < ApplicationController
  include Filterable
  include ApplicationHelper
  include MeetingRoomsHelper

  before_action :authorize_user, except: [:index]

  before_action :init_breadcrumbs
  before_action :prepared_meeting_room, only: [:schedule, :create, :book]
  before_action :prepared_meeting_reservation_data, only: [:create, :book]
  before_action :prepared_meeting_reservation, only: [:schedule, :book]

  def index
    @filter_history, @departments_rooms = filter!(Room)
    @departments_rooms = @departments_rooms.group_by(&:department)
  end

  def schedule
    add_breadcrumb params[:id]
    add_breadcrumb 'Schedule'
  end

  def events
    @events = MeetingReservation.where('room_id = ?', params[:id])
    @meeting_reservations = @events.flat_map { |event| event.events(params[:end]) }

    grouped_schedules = remove_overlap_events(@meeting_reservations)
    formatted_meeting_reservations = response_reservations(grouped_schedules.values.flatten)

    respond_to do |format|
      format.json { render json: formatted_meeting_reservations }
    end
  end

  def book
    add_breadcrumb params[:id]
    add_breadcrumb 'Book'

    @user_list = User.where.not(id: current_user.id)

    respond_to do |format|
      format.html { render 'book' }
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update('modal-title') { 'Book Room' },
          turbo_stream.update('modal-body', partial: 'book_form', locals: { meeting_reservation: @meeting_reservation, data_controller: @data_controller })
        ]
      end
    end
  end

  def create
    @meeting_reservation = MeetingReservation.new(meeting_reservation_params.merge(room_id: params[:id], book_by: current_user))
    @selected_rule = @meeting_reservation.rule_to_option

    event = @meeting_reservation.create_calendar_event if @meeting_reservation.valid?

    begin
      google_event = GoogleCalendarManager::Creator.new(authorization: session[:authorization], event: event).call if event.present?
    rescue Google::Apis::AuthorizationError => _e
      client, _service = GoogleCalendarManager::Initializer.new(session[:authorization]).call
      session[:authorization] = session[:authorization].merge(client.refresh!)
      retry
    end

    if google_event.present?
      @meeting_reservation.calendar_event = google_event.id
      reservation = @meeting_reservation.save
    end

    respond_to do |format|
      if reservation.present?
        format.html { redirect_to details_meeting_room_path(params[:id]), notice: 'Meeting reservation was successfully created.' }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.update('modal-body', partial: 'book_form', locals: { data_controller: 'flatpickr' }), status: :unprocessable_entity }
      end
    end
  end

  private

  def init_breadcrumbs
    add_breadcrumb 'Meeting Rooms'
  end

  def prepared_meeting_room
    @meeting_room = Room.includes(:department).find(params[:id])
  end

  def prepared_meeting_reservation_data
    @user_list = User.where.not(id: current_user.id)
    @meeting_description = "<p>You're warmly invited to a meeting at <strong>#{@meeting_room.name} - #{@meeting_room.department.address}</strong></strong>.<br /><br />Your input is highly appreciated, so please mark your calendar and endeavor to arrive on time.</p>"
  end

  def prepared_meeting_reservation
    @meeting_reservation = MeetingReservation.new
  end

  def authorize_user
    unless session[:authorization].present?
      flash[:alert] = 'You should be logged in with a Google account to use this feature.'
      redirect_to meeting_rooms_path
    end
  end

  def meeting_reservation_params
    params[:meeting_reservation][:member_ids] = params[:meeting_reservation][:member_ids].split(',').map(&:strip) || []
    params.require(:meeting_reservation).permit(:title, :note, :recurring, :book_at, :start_time, :end_time, :team_id, member_ids: [])
  end

  def remove_overlap_events(meeting_reservations)
    # handle Calendar overlap recurring - recurring UI show
    grouped_schedules = meeting_reservations.group_by { |schedule| schedule.book_at.strftime('%Y-%m-%d') }

    grouped_schedules.each do |date, events|
      events.sort_by!(&:created_at)

      non_overlapping_events = [events.first]

      events.each do |event|
        overlapping = non_overlapping_events.any? do |non_overlap_event|
          (event.start_time < non_overlap_event.end_time) && (event.end_time > non_overlap_event.start_time)
        end

        non_overlapping_events << event unless overlapping
      end

      grouped_schedules[date] = non_overlapping_events
    end
  end

  def response_reservations(reservations)
    reservations.map do |reservation|
      {
        title: reservation.title,
        start: format_datetime(reservation.start_datetime),
        end: format_datetime(reservation.end_datetime),
        color: determine_color(reservation, current_user),
        url: determine_url(reservation, current_user)
      }
    end
  end
end

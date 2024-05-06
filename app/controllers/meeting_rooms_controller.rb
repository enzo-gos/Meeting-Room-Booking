class MeetingRoomsController < ApplicationController
  include Filterable
  include GoogleCalendar

  before_action :init_breadcrumbs
  before_action :authorize_user, only: [:schedule]

  def index
    @filter_history, @departments_rooms = filter!(Room)
    @departments_rooms = @departments_rooms.group_by(&:department)
  end

  def schedule
    add_breadcrumb params[:id]
    add_breadcrumb 'Schedule'

    @meeting_room = Room.find(params[:id])

    @meeting_reservation = MeetingReservation.new
  end

  def events
    start_date = params[:start]
    end_date = params[:end]

    @meeting_reservations = MeetingReservation.where('book_at >= ? AND book_at <= ? AND room_id = ?', start_date, end_date, params[:id])

    formatted_meeting_reservations = @meeting_reservations.map do |reservation|
      start_datetime = combine_date_time(reservation.book_at, reservation.start_time)
      end_datetime = combine_date_time(reservation.book_at, reservation.end_time)

      {
        title: reservation.title,
        start: start_datetime.strftime('%Y-%m-%d %H:%M:%S'),
        end: end_datetime.strftime('%Y-%m-%d %H:%M:%S'),
        color: reservation.book_by_id == current_user.id ? 'green' : 'sky'
      }
    end

    respond_to do |format|
      format.json { render json: formatted_meeting_reservations }
    end
  end

  def book
    add_breadcrumb params[:id]
    add_breadcrumb 'Book'

    @meeting_reservation = MeetingReservation.new

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update('modal-title') { 'Book Room' },
          turbo_stream.update('modal-body', partial: 'book_form', locals: { meeting_reservation: @meeting_reservation, data_controller: @data_controller })
        ]
      end
    end
  end

  def create
    @meeting_reservation = MeetingReservation.create(meeting_reservation_params.merge(room_id: params[:id], book_by: current_user))
    valid = @meeting_reservation.valid?

    if valid
      begin
        start_date_time = combine_date_time(@meeting_reservation.book_at, @meeting_reservation.start_time).strftime('%Y-%m-%dT%H:%M:%S%:z')
        end_date_time = combine_date_time(@meeting_reservation.book_at, @meeting_reservation.end_time).strftime('%Y-%m-%dT%H:%M:%S%:z')

        create_new_event(
          title: @meeting_reservation.title,
          start_date: start_date_time,
          end_date: end_date_time,
          members: @meeting_reservation.members.to_a.map { |el| { email: el.email } },
          note: @meeting_reservation.note.body.to_s
        )
      rescue Google::Apis::AuthorizationError => _e
        client = initialize_client
        response = client.refresh!
        session[:authorization] = session[:authorization].merge(response)
        retry
      end
    end

    respond_to do |format|
      if @meeting_reservation.save
        format.html { redirect_to details_meeting_room_path(params[:id]), notice: 'Meeting reservation was successfully created.' }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.update('modal-body', partial: 'book_form'), status: :unprocessable_entity }
      end
    end
  end

  private

  def init_breadcrumbs
    add_breadcrumb 'Meeting Rooms'
  end

  def authorize_user
    session[:calendar_callback_url] = details_meeting_room_url(params[:id])
    redirect_to google_calendar_path unless session[:authorization].present?
  end

  def meeting_reservation_params
    params[:meeting_reservation][:member_ids] = params[:meeting_reservation][:member_ids].split(',').map(&:strip) || []
    params.require(:meeting_reservation).permit(:title, :note, :book_at, :start_time, :end_time, member_ids: [])
  end

  def combine_date_time(date, time)
    date_time = date + time.seconds_since_midnight.seconds
    DateTime.new(date_time.year, date_time.month, date_time.day, date_time.hour, date_time.min, date_time.sec, '+07:00')
  end
end

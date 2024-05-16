class MeetingRoomsController < ApplicationController
  include Filterable
  include GoogleCalendar

  before_action :init_breadcrumbs
  before_action :init_meeting_room, only: [:schedule, :create, :book]
  before_action :init_meeting_descriptions, only: [:create, :book]
  before_action :authorize_user, only: [:schedule]

  def index
    @filter_history, @departments_rooms = filter!(Room)
    @departments_rooms = @departments_rooms.group_by(&:department)
  end

  def schedule
    add_breadcrumb params[:id]
    add_breadcrumb 'Schedule'

    @meeting_reservation = MeetingReservation.new
  end

  def events
    end_date = params[:end]

    @events = MeetingReservation.where('room_id = ?', params[:id])
    @meeting_reservations = @events.flat_map do |e|
      e.events(end_date)
    end

    grouped_schedules = remove_overlap_events(@meeting_reservations)

    formatted_meeting_reservations = grouped_schedules.values.flatten.map do |reservation|
      start_datetime = reservation.start_datetime
      end_datetime = reservation.end_datetime

      view_params = reservation.recurring? ? { id: reservation.id, recurring: start_datetime.to_i } : { id: reservation.id }

      color = 'grey'
      color = 'green' if reservation.book_by_id == current_user.id && !reservation.outdated
      color = 'sky' if reservation.book_by_id != current_user.id && !reservation.outdated

      {
        title: reservation.title,
        start: start_datetime.strftime('%Y-%m-%d %H:%M:%S'),
        end: end_datetime.strftime('%Y-%m-%d %H:%M:%S'),
        color: color,
        url: current_user.id == reservation.book_by_id && !reservation.outdated ? edit_reservation_path(view_params) : reservation_path(view_params)
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
    @user_list = User.where.not(id: current_user.id)
    @meeting_reservation = MeetingReservation.create(meeting_reservation_params.merge(room_id: params[:id], book_by: current_user))

    @selected_rule = @meeting_reservation.rule_to_option

    valid = @meeting_reservation.valid?

    if valid
      begin
        start_date_time = @meeting_reservation.start_datetime_with_recurring.strftime('%Y-%m-%dT%H:%M:%S%:z')
        end_date_time = @meeting_reservation.end_datetime_with_recurring.strftime('%Y-%m-%dT%H:%M:%S%:z')

        new_event = create_new_event(
          title: @meeting_reservation.title,
          start_date: start_date_time,
          end_date: end_date_time,
          members: @meeting_reservation.allmembers,
          note: @meeting_reservation.note.body.to_s,
          recurrence: @meeting_reservation.recurring? ? [@meeting_reservation.google_calendar_rule] : []
        )

        @meeting_reservation.calendar_event = new_event.id
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
        format.turbo_stream { render turbo_stream: turbo_stream.update('modal-body', partial: 'book_form', locals: { data_controller: 'flatpickr' }), status: :unprocessable_entity }
      end
    end
  end

  private

  def init_breadcrumbs
    add_breadcrumb 'Meeting Rooms'
  end

  def init_meeting_room
    @meeting_room = Room.includes(:department).find(params[:id])
  end

  def init_meeting_descriptions
    @meeting_description = "<p>You're warmly invited to a meeting at <strong>#{@meeting_room.name} - #{@meeting_room.department.address}</strong></strong>.<br /><br />Your input is highly appreciated, so please mark your calendar and endeavor to arrive on time.</p>"
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
end

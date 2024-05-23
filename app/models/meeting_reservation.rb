# == Schema Information
#
# Table name: meeting_reservations
#
#  id         :bigint           not null, primary key
#  title      :string
#  room_id    :bigint           not null
#  book_by_id :bigint           not null
#  book_at    :date
#  start_time :time
#  end_time   :time
#  team_id    :bigint
#  recurring  :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class MeetingReservation < ApplicationRecord
  require 'ice_cube'
  include DateTimeMethods
  include SchedulesHelper
  include ReservationJobs

  attr_accessor :_skip_callback

  serialize :recurring, type: Hash, coder: JSON
  serialize :extimes, type: Array, coder: JSON

  has_rich_text :description
  has_rich_text :note

  belongs_to :room
  belongs_to :book_by, class_name: :User
  belongs_to :team, optional: true

  has_and_belongs_to_many :members, class_name: :User, join_table: :meeting_invitations, dependent: :destroy

  validates :title, presence: { message: 'Title must be provided' }
  validates :book_at, presence: { message: 'Book at must be provided' }
  validates :start_time, presence: { message: 'Start time must be provided' }
  validates :end_time, presence: { message: 'End time must be provided' }
  validate -> { errors.add(:base, 'Invitation must be included.') if members.empty? && team_id.nil? }

  validate :start_time_less_than_end_time
  validate :time_difference_in_15_minutes
  validate :booking_before_30min_started

  validate :does_not_conflict, if: :new_or_changed
  validate :does_not_overlap_single_recurring, if: :new_or_changed
  validate :does_not_overlap_recurring, if: :new_or_changed

  scope :with_room_department, -> { includes(room: :department) }
  scope :by_book_by, ->(book_by_id) { where(book_by_id: book_by_id) if book_by_id.present? }
  scope :by_schedule, -> { where(outdated: false) }
  scope :by_history, -> { where(outdated: true) }

  after_create_commit :perform_to_create_history, unless: :_skip_callback
  after_destroy_commit :perform_to_delete_history, unless: :_skip_callback
  after_commit -> { SendEventJob.perform_async(to_json) }

  before_save -> { self.book_at = start_datetime_with_recurring }

  # check overlap single event - single event
  def does_not_conflict
    return if recurring?

    book_at_str = book_at&.strftime('%Y-%m-%d')

    overlapping_events = MeetingReservation.where('room_id = ? AND start_time < ? AND end_time > ? AND book_at = ?', room_id, end_time, start_time, book_at_str).where(recurring: nil)
    overlapping_events = overlapping_events.where.not(id: id) unless id.nil?

    if overlapping_events.exists?
      errors.add(:base, 'A meeting has already been booked at this time.')
    end
  end

  # check overlap recurring - recurring
  def does_not_overlap_recurring
    return if outdated == true
    return unless recurring?
    return unless start_time && end_time

    overlapping_events = MeetingReservation.where('room_id = ? AND start_time < ? AND end_time > ? AND recurring = ? AND outdated = false', room_id, end_time, start_time, recurring.to_json)
    overlapping_events = overlapping_events.where.not(id: id) unless id.nil?

    if overlapping_events.exists?
      errors.add(:base, 'A meeting has already been booked at this time.')
    end
  end

  # check overlap single - recurring
  def does_not_overlap_single_recurring
    return if outdated == true
    return unless recurring.empty?
    return unless start_time && end_time

    overlapping_meeting = find_overlapping_meeting

    if overlapping_meeting
      errors.add(:base, 'A meeting has already been booked at this time.')
    end
  end

  def start_time_less_than_end_time
    return unless start_time && end_time

    if start_time >= end_time
      errors.add(:start_time, 'Start time must be less than end time')
    end
  end

  def time_difference_in_15_minutes
    return unless start_time && end_time

    if (end_time - start_time) < 15.minutes
      errors.add(:base, 'The meeting must last at least 15 minutes from the start time.')
    end
  end

  def booking_before_30min_started
    return unless book_at
    return unless start_time

    begin_time = start_datetime_with_recurring.to_time
    time_now = Time.now

    if begin_time < time_now || begin_time - time_now < 30.minutes
      errors.add(:base, 'The meeting must be booked at least 30 minutes before meeting start  .')
    end
  end

  def start_datetime_with_recurring
    return start_datetime unless recurring?

    build_datetime(calculate_datetime(schedule(book_at).first, start_time))
  end

  def end_datetime_with_recurring
    return end_datetime unless recurring?

    build_datetime(calculate_datetime(schedule(book_at).first, end_time))
  end

  def start_datetime
    build_datetime(calculate_datetime(book_at, start_time))
  end

  def end_datetime
    build_datetime(calculate_datetime(book_at, end_time))
  end

  def recurring=(value)
    super(RecurringSelect.is_valid_rule?(value) ? RecurringSelect.dirty_hash_to_rule(value).to_hash : nil)
  end

  def extimes=(value)
    processed_value = !value.nil? && value.is_a?(Array) ? value : [value]
    super(value.nil? ? [] : processed_value)
  end

  def ice_cube_rule
    IceCube::Rule.from_hash recurring
  end

  def google_calendar_rule
    pattern = /^(RRULE|EXRULE|RDATE|EXDATE).*$/

    event = google_calendar_schedule(book_at)

    lines = event.to_ical.split("\n")
    filtered_lines = lines.select { |line| line.match?(pattern) }

    filtered_lines.join("\n")
  end

  def schedule(start_date)
    IceCube::Schedule.new(start_date) do |s|
      s.add_recurrence_rule(ice_cube_rule)
      extimes.each { |time| s.add_exception_time(time.to_date) }
    end
  end

  def google_calendar_schedule(start_date)
    IceCube::Schedule.new(start_date) do |s|
      s.add_recurrence_rule(ice_cube_rule)
      extimes.each { |time| s.add_exception_time(time.to_datetime) }
    end
  end

  def events(end_date)
    return [self] if !recurring? || outdated == true

    end_date = end_date.to_date if end_date
    end_frequency = end_date || Date.today + 1.month

    schedule(book_at).occurrences(end_frequency).map do |date|
      MeetingReservation.new(
        id: id,
        title: title,
        book_at: date,
        start_time: start_time,
        end_time: end_time,
        recurring: recurring,
        book_by_id: book_by_id,
        room_id: room_id,
        outdated: outdated,
        extimes: extimes,
        calendar_event: calendar_event,
        created_at: created_at
      )
    end
  end

  def allmembers
    team_users = team&.users.to_a.map { |el| { email: el.email } }
    member_emails = members.to_a.map { |el| { email: el.email } }

    team_users | member_emails
  end

  def recurring?
    !recurring.empty?
  end

  def occurrence?(date_time)
    schedule(date_time).occurs_at?(date_time)
  end

  def next_occurrence
    schedule(book_at).next_occurrence(book_at)
  end

  def except_date(date)
    date_time = date.to_datetime
    rule = IceCube::Schedule.new do |s|
      time = Time.at(build_datetime(date_time))
      s.add_exception_time(time)
    end
    rule.extimes
  end

  def to_calendar_event
    create_calendar_event.merge({ event_id: calendar_event })
  end

  def create_calendar_event
    {
      title: title,
      start_date: iso_string(start_datetime_with_recurring),
      end_date: iso_string(end_datetime_with_recurring),
      members: allmembers,
      note: note.body.to_s,
      recurrence: recurring? ? [google_calendar_rule] : [],
      calendar_id: 'primary'
    }
  end

  def perform_to_update_history
    schedule_job(id)&.reschedule(start_datetime_with_recurring)
    monthly_job(id)&.delete
    MonthlyBookJob.perform_async(id, start_datetime_with_recurring.to_i) if recurring?
  end

  private

  def new_or_changed
    (new_record? && !persisted?) || changed?
  end

  def find_overlapping_meeting
    reservations = MeetingReservation.where('room_id = ? AND outdated = false', room_id)
    reservations = reservations.where.not(id: id) unless id.nil?

    recurring_meetings = reservations.flat_map { |e| e.events(end_datetime) }
    recurring_meetings.find do |e|
      overlap?(e)
    end
  end

  def overlap?(meeting)
    meeting.book_at == book_at && meeting.start_time < end_time && meeting.end_time > start_time
  end

  def perform_to_create_history
    return if outdated

    ReservationScheduleJob.perform_at(start_datetime_with_recurring, id)
    MonthlyBookJob.perform_async(id, start_datetime_with_recurring.to_i) if recurring?
  end

  def perform_to_delete_history
    schedule_job(id)&.delete
    monthly_job(id)&.delete if recurring?
  end
end

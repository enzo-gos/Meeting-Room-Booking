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

  FILTER_PARAMS = %i[title book_at start_time room_id].freeze

  serialize :recurring, type: Hash, coder: JSON

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

  validate :does_not_conflict, if: -> { (new_record? && !persisted?) || changed? }
  validate :start_time_less_than_end_time
  validate :time_difference_in_15_minutes
  validate :does_not_overlap_single_recurring, if: -> { (new_record? && !persisted?) || changed? }
  validate :does_not_overlap_recurring, if: -> { (new_record? && !persisted?) || changed? }

  validate :invitation_required

  scope :with_room_department, -> { includes(room: :department) }

  scope :by_title, ->(query) { where('meeting_reservations.title ilike ?', "%#{query}%") }
  scope :by_room, ->(room_id) { where(room_id: room_id) if room_id.present? }
  scope :by_book_by, ->(book_by_id) { where(book_by_id: book_by_id) if book_by_id.present? }
  scope :by_book_at, ->(book_at) { where(book_at: book_at).where(recurring: nil) if book_at.present? }
  scope :by_start_time, ->(start_time) { where(start_time: start_time) if start_time.present? }

  def self.filter(filters)
    MeetingReservation
      .includes([:room])
      .with_room_department
      .order(:created_at)
      .by_room(filters['room_id'])
      .by_title(filters['title'])
      .by_book_at(filters['book_at'])
      .by_start_time(filters['start_time'])
  end

  # check overlap single event - single event
  def does_not_conflict
    return unless recurring.empty?

    book_at_str = book_at&.strftime('%Y-%m-%d')

    overlapping_events = MeetingReservation.where('(start_time < ? AND end_time > ?) AND book_at = ?', end_time, start_time, book_at_str).where(recurring: nil)
    overlapping_events = overlapping_events.where.not(id: id) unless id.nil?

    if overlapping_events.exists?
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

  # check overlap recurring - recurring
  def does_not_overlap_recurring
    return if recurring.empty?
    return unless start_time && end_time

    overlapping_events = MeetingReservation.where('(start_time < ? AND end_time > ?) AND recurring = ?', end_time, start_time, recurring.to_json)
    overlapping_events = overlapping_events.where.not(id: id) unless id.nil?

    if overlapping_events.exists?
      errors.add(:base, 'A meeting has already been booked at this time.')
    end
  end

  # check overlap single - recurring
  def does_not_overlap_single_recurring
    return unless recurring.empty?
    return unless start_time && end_time

    overlapping_meeting = find_overlapping_meeting

    if overlapping_meeting
      errors.add(:base, 'A meeting has already been booked at this time.')
    end
  end

  def start_datetime
    date_time = book_at + start_time.seconds_since_midnight.seconds
    DateTime.new(date_time.year, date_time.month, date_time.day, date_time.hour, date_time.min, date_time.sec, '+07:00')
  end

  def end_datetime
    date_time = book_at + end_time.seconds_since_midnight.seconds
    DateTime.new(date_time.year, date_time.month, date_time.day, date_time.hour, date_time.min, date_time.sec, '+07:00')
  end

  def start_datetime_with_recurring
    return start_datetime if recurring.empty?

    date_time = schedule(book_at).first + start_time.seconds_since_midnight.seconds
    DateTime.new(date_time.year, date_time.month, date_time.day, date_time.hour, date_time.min, date_time.sec, '+07:00')
  end

  def end_datetime_with_recurring
    return end_datetime if recurring.empty?

    date_time = schedule(book_at).first + end_time.seconds_since_midnight.seconds
    DateTime.new(date_time.year, date_time.month, date_time.day, date_time.hour, date_time.min, date_time.sec, '+07:00')
  end

  def recurring=(value)
    if RecurringSelect.is_valid_rule?(value)
      super(RecurringSelect.dirty_hash_to_rule(value).to_hash)
    else
      super(nil)
    end
  end

  def ice_cube_rule
    IceCube::Rule.from_hash recurring
  end

  def google_calendar_rule
    pattern = /^(RRULE|EXRULE|RDATE|EXDATE):\S*/

    event = IceCube::Schedule.new
    event.add_recurrence_rule(ice_cube_rule)

    lines = event.to_ical.split("\n")
    filtered_lines = lines.select { |line| line.match?(pattern) }

    filtered_lines.join("\n")
  end

  def schedule(start_date)
    schedule = IceCube::Schedule.new(start_date)
    schedule.add_recurrence_rule(ice_cube_rule)

    schedule
  end

  def events(end_date)
    return [self] if recurring.empty?

    end_date = end_date.to_date if end_date

    end_frequency = end_date || Date.today + 1.month

    schedule(book_at).occurrences(end_frequency).map do |date|
      MeetingReservation.new(id: id, title: title, book_at: date, start_time: start_time, end_time: end_time, recurring: recurring, book_by_id: book_by_id, room_id: room_id, created_at: created_at)
    end
  end

  def invitation_required
    errors.add(:base, 'Invitation must be included.') if members.empty? && team_id.nil?
  end

  def allmembers
    team_users = team&.users.to_a.map { |el| { email: el.email } }
    member_emails = members.to_a.map { |el| { email: el.email } }

    team_users | member_emails
  end

  def rule_to_option
    return nil if recurring.empty?

    rule = RecurringSelect.dirty_hash_to_rule(ice_cube_rule)
    ar = [rule.to_s, rule.to_hash.to_json]

    ar[0] += '*'
    ar << { 'data-custom' => true }
    ar
  end

  private

  def find_overlapping_meeting
    reservations = MeetingReservation.where('room_id = ?', room_id)
    reservations = reservations.where.not(id: id) unless id.nil?

    recurring_meetings = reservations.flat_map { |e| e.events(end_datetime) }

    recurring_meetings.find do |e|
      overlap?(e)
    end
  end

  def overlap?(meeting)
    meeting.book_at == book_at && meeting.start_time < end_time && meeting.end_time > start_time
  end
end

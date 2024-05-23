module MeetingReservation::OverlapValidator
  extend ActiveSupport::Concern

  included do
    validate :does_not_conflict, if: :new_or_changed
    validate :does_not_overlap_single_recurring, :new_or_changed
    validate :does_not_overlap_recurring, :new_or_changed
  end

  private

  def new_or_changed
    (new_record? && !persisted?) || changed?
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

  # check overlap recurring - recurring
  def does_not_overlap_recurring
    return if outdated == true
    return unless recurring?
    return unless start_time && end_time

    overlapping_events = MeetingReservation.where('(start_time < ? AND end_time > ?) AND recurring = ? AND outdated = false', end_time, start_time, recurring.to_json)
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
end

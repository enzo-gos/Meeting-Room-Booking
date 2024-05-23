module MeetingReservation::BookTimeValidator
  extend ActiveSupport::Concern

  included do
    validate :start_time_less_than_end_time
    validate :time_difference_in_15_minutes
    validate :booking_before_30min_started
  end

  private

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
end

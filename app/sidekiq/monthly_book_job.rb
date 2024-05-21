class MonthlyBookJob
  include Sidekiq::Job
  include SchedulesHelper

  def perform(reservation_id, from = -1)
    from_datetime = from == -1 || !from.is_a?(Integer) ? Time.now : Time.at(from)
    MonthlyBookJob.perform_at(SchedulesHelper.next_month(from: from_datetime), reservation_id)

    reservations = MeetingReservation.includes(:book_by, :room, :members).where.not(recurring: nil, outdated: true)

    meeting_reservations = reservations.flat_map do |e|
      e.events(Time.now.utc.end_of_month)
    end

    overlaps, none_overlap = fetch_overlap(meeting_reservations)

    return if overlaps.empty?

    overlaps.each do |event|
      if event.id == reservation_id
        overlap_with = none_overlap[event.book_at.strftime('%Y-%m-%d')].find { |overlap| (event.start_time < overlap.end_time) && (event.end_time > overlap.start_time) }
        BookSchedulerMailer.overlap_reservation_email(event.to_json, overlap_with&.to_json).deliver_later
      end
    end
  end

  def fetch_overlap(meeting_reservations)
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

    [meeting_reservations - grouped_schedules.values.flatten, grouped_schedules]
  end
end

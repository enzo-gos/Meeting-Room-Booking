class ReservationScheduleJob
  include Sidekiq::Job

  def perform(reservation_id)
    event = MeetingReservation.find(reservation_id)

    if event.recurring?
      ReservationScheduleJob.perform_at(event.start_datetime_with_recurring, event.id)

      old_event = event.dup
      old_event.book_at = event.book_at
      old_event.note = event.note
      old_event.members = event.members.to_a
      old_event.outdated = true
      old_event.save
    else
      event.outdated = true
      event.save
    end
  end
end

class ReservationScheduleJob
  include Sidekiq::Job

  def perform(reservation_id)
    event = MeetingReservation.find(reservation_id)

    if event.recurring?
      old_book_at = event.book_at

      if event.update(book_at: event.next_occurrence.strftime('%Y-%m-%d'))
        ReservationScheduleJob.perform_at(event.start_datetime_with_recurring, event.id, 'create')
      end

      if event.occurrence?(event.book_at)
        old_event = event.dup

        old_event.book_at = old_book_at
        old_event.members = event.members.to_a
        old_event.outdated = true
        old_event.save
        ActionCable.server.broadcast "room_channel_#{meeting_reservation.room_id}", { event: event, refetch: true }
      end
    else
      event.outdated = true
      event.save
      ActionCable.server.broadcast "room_channel_#{meeting_reservation.room_id}", { event: event, refetch: true }
    end
  end
end

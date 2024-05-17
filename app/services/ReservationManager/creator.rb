module ReservationManager
  class Creator < ApplicationService
    def initialize(meeting_reservation)
      @meeting_reservation = meeting_reservation
    end

    def call
      create
    end

    private

    def create
      return nil unless @meeting_reservation.valid?

      {
        title: @meeting_reservation.title,
        start_date: @meeting_reservation.start_datetime_with_recurring.strftime('%Y-%m-%dT%H:%M:%S%:z'),
        end_date: @meeting_reservation.end_datetime_with_recurring.strftime('%Y-%m-%dT%H:%M:%S%:z'),
        members: @meeting_reservation.allmembers,
        note: @meeting_reservation.note.body.to_s,
        recurrence: @meeting_reservation.recurring? ? [@meeting_reservation.google_calendar_rule] : []
      }
    end
  end
end

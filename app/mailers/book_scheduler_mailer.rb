class BookSchedulerMailer < ApplicationMailer
  def new_reservation_email
    @reservation = params[:reservation]
    mail(to: @reservation.book_by.email, subject: 'Notice: Meeting Reservation')
  end

  def overlap_reservation_email(event, overlap_event)
    @reservation = MeetingReservation.new(JSON.parse(event))
    @overlap_reservation = MeetingReservation.new(JSON.parse(overlap_event))

    mail(to: @reservation.book_by.email, subject: 'Overlap: Meeting Reservation')
  end
end

class BookSchedulerMailer < ApplicationMailer
  def new_reservation_email
    @reservation = params[:reservation]
    mail(to: @reservation.book_by.email, subject: 'Notice: Meeting Reservation')
  end

  def overlap_reservation_email(evt)
    @reservation = MeetingReservation.new(JSON.parse(evt))

    mail(to: @reservation.book_by.email, subject: 'Overlap: Meeting Reservation')
  end
end

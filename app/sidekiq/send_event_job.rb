class SendEventJob
  include Sidekiq::Job

  def perform(meeting_reservation_json)
    meeting_reservation = MeetingReservation.new(JSON.parse(meeting_reservation_json))
    ActionCable.server.broadcast "room_channel_#{meeting_reservation.room_id}", { event: meeting_reservation, refetch: true }
  end
end

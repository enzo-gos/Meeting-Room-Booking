class SendEventJob < ApplicationJob
  queue_as :default

  def perform(meeting_reservation)
    ActionCable.server.broadcast "room_channel_#{meeting_reservation.room_id}", { event: meeting_reservation, refetch: true }
  end
end

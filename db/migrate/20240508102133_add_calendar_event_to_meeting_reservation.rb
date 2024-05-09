class AddCalendarEventToMeetingReservation < ActiveRecord::Migration[7.1]
  def change
    add_column :meeting_reservations, :calendar_event, :string
  end
end

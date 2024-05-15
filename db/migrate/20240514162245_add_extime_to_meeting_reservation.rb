class AddExtimeToMeetingReservation < ActiveRecord::Migration[7.1]
  def change
    add_column :meeting_reservations, :extimes, :text
  end
end

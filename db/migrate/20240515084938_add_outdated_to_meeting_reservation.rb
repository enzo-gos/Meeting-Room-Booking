class AddOutdatedToMeetingReservation < ActiveRecord::Migration[7.1]
  def change
    add_column :meeting_reservations, :outdated, :boolean, default: false
  end
end

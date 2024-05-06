class CreateMeetingRoomInvitations < ActiveRecord::Migration[7.1]
  def change
    create_table :meeting_room_invitations do |t|
      t.references :meeting_reservation, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end

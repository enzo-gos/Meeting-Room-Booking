class CreateMeetingReservations < ActiveRecord::Migration[7.1]
  def change
    create_table :meeting_reservations do |t|
      t.string :title
      t.references :room, null: false, foreign_key: true
      t.references :book_by, null: false, foreign_key: { to_table: :users }
      t.date :book_at
      t.time :start_time
      t.time :end_time
      t.references :team, null: true, foreign_key: true
      t.text :recurring

      t.timestamps
    end

    create_join_table :meeting_reservations, :users, table_name: :meeting_invitations do |t|
      t.index [:meeting_reservation_id, :user_id]
      t.index [:user_id, :meeting_reservation_id]
    end
  end
end

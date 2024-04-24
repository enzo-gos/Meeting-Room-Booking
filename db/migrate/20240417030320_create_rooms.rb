class CreateRooms < ActiveRecord::Migration[7.1]
  def change
    create_table :rooms do |t|
      t.string :name
      t.references :department, null: false, foreign_key: true
      t.integer :max_capacity
      t.string :description

      t.timestamps
    end

    create_join_table :rooms, :facilities do |t|
      t.index [:room_id, :facility_id]
      t.index [:facility_id, :room_id]
    end
  end
end

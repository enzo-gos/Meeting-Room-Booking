class AddUniqueIndexToRooms < ActiveRecord::Migration[7.1]
  def change
    add_index :rooms, [:name, :department_id], unique: true
  end
end

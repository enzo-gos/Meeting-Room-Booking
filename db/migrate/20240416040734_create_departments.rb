class CreateDepartments < ActiveRecord::Migration[7.1]
  def change
    create_table :departments do |t|
      t.string :name
      t.string :description
      t.string :address

      t.timestamps
    end
  end
end

class AddUserInfoToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :firstname, :string
    add_column :users, :lastname, :string

    change_table :users, bulk: true do |t|
      t.string :provider
      t.string :uid
     end
  end
end

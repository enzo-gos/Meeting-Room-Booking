class CreateTeams < ActiveRecord::Migration[7.1]
  def change
    create_table :teams do |t|
      t.string :name

      t.timestamps
    end

    create_join_table :teams, :users do |t|
      t.index [:team_id, :user_id]
      t.index [:user_id, :team_id]
    end
  end
end

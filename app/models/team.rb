class Team < ApplicationRecord
  has_many :users, through: :user_teams
end

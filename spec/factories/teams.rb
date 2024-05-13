# spec/factories/teams.rb
FactoryBot.define do
  factory :team do
    name { Faker::Team.name }
  end
end

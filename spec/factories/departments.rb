FactoryBot.define do
  factory :department do
    name { Faker::Educator.subject }
  end
end

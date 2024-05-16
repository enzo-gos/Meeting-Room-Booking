# spec/factories/meeting_reservations.rb
FactoryBot.define do
  factory :meeting_reservation do
    _skip_callback { true }
    title { Faker::Lorem.sentence }
    room
    book_by { association(:user) }
    members { [association(:user)] }
    team
    book_at { Date.today }
    start_time { Faker::Time.between(from: DateTime.now, to: DateTime.now + 7, format: :default) }
    end_time { start_time + 1.hour }
  end
end

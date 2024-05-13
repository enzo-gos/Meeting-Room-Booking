FactoryBot.define do
  factory :room do
    name { "#{Faker::Company.unique.name} Room" }
    association :department
    max_capacity { Faker::Number.between(from: 3, to: 200) }
    preview_image { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'images', 'room.jpg'), 'image/jpeg') }

    after(:build) do |room|
      room.facilities << FactoryBot.create(:facility)
    end
  end
end

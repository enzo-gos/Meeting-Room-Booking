# spec/factories/users.rb

password = Faker::Internet.password(min_length: 8)

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { password }
    provider { 'google' }
    uid { Faker::Number.number(digits: 10) }
    current_password { password }
  end
end

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

admin_role = Role.create!(name: 'admin')
Role.create!(name: 'user')

# generate some service of meeting room
Facility.create!(name: 'Internet', description: 'Reliable and fast internet connection for seamless online activities during meetings')
Facility.create!(name: 'Projector', description: 'A device for projecting images onto a screen or wall')
Facility.create!(name: 'Whiteboard', description: 'A smooth, glossy surface for writing on with markers, typically used for presentations and brainstorming sessions')
Facility.create!(name: 'Video Conferencing', description: 'Equipment and software for conducting remote meetings with audio and video capabilities')
Facility.create!(name: 'Refreshments', description: 'Beverages and snacks provided for meeting attendees')
Facility.create!(name: 'Flipchart', description: 'A large pad of paper attached to a stand, used for presenting information or brainstorming ideas with markers')
Facility.create!(name: 'Comfortable Seating', description: 'Chairs designed for long periods of sitting, providing ergonomic support and comfort')
Facility.create!(name: 'Climate Control', description: 'Heating, ventilation, and air conditioning systems to maintain a comfortable temperature')

Department.create!(name: 'Golden Owl Q3', description: 'The department at CMT-8 street', address: '538 CMT 8 street, district 3 HCMC')
Department.create!(name: 'Golden Owl Q2', description: 'The department at Sala', address: 'district 2 HCMC')

random_password = Devise.friendly_token[0, 20]

User.create!(
  id: 2,
  email: 'enzo.nguyen.gos@gmail.com',
  password: random_password,
  password_confirmation: random_password,
  reset_password_token: nil,
  reset_password_sent_at: nil,
  remember_created_at: nil,
  created_at: '2024-04-19 15:37:29.490271',
  updated_at: '2024-04-19 15:37:29.490271',
  firstname: nil,
  lastname: nil,
  provider: 'google',
  uid: '113354911838389532580'
)

User.create!(
  id: 1,
  email: 'nducminh.it@gmail.com',
  password: '123123',
  password_confirmation: '123123',
  reset_password_token: nil,
  reset_password_sent_at: nil,
  remember_created_at: nil,
  created_at: '2024-04-17 03:17:33.787963',
  updated_at: '2024-04-21 16:01:44.489933',
  firstname: nil,
  lastname: nil,
  provider: nil,
  uid: nil
)

User.create!(
  id: 3,
  email: 'admin@gmail.com',
  password: '123123',
  password_confirmation: '123123',
  reset_password_token: nil,
  reset_password_sent_at: nil,
  remember_created_at: nil,
  created_at: '2024-04-22 03:17:44.970778',
  updated_at: '2024-04-22 03:17:44.970778',
  firstname: nil,
  lastname: nil,
  provider: nil,
  uid: nil
)

User.create!(
  id: 4,
  email: 'test.user@gmail.com',
  password: '123123',
  password_confirmation: '123123',
  reset_password_token: nil,
  reset_password_sent_at: nil,
  remember_created_at: nil,
  created_at: '2024-05-02 03:24:23.25183',
  updated_at: '2024-05-02 03:24:23.25183',
  firstname: nil,
  lastname: nil,
  provider: nil,
  uid: nil
)

# Create teams
team_alpha = Team.create!(name: 'Ruby Alpha')
team_beta = Team.create!(name: 'Ruby Beta')
team_ld = Team.create!(name: 'L&D')

# Find users
user1 = User.find_by(email: 'enzo.nguyen.gos@gmail.com')
user2 = User.find_by(email: 'nducminh.it@gmail.com')
user3 = User.find_by(email: 'dev1.gos@gmail.com')
user4 = User.find_by(email: 'dev2.gos@gmail.com')

# Assign users to teams
user1.teams << team_alpha
user2.teams << team_beta
user3.teams << team_ld
user4.teams << team_alpha  # You can assign a user to multiple teams if needed

user2.roles << admin_role

# Save the users to persist the associations to the database
user1.save
user2.save
user3.save
user4.save

# Ensure admin role exists
admin_role = Role.find_or_create_by!(name: 'admin')

# Ensure user role exists
user_role = Role.find_or_create_by!(name: 'user')

# Create facilities if they don't exist
facilities_data = [
  { name: 'Internet', description: 'Reliable and fast internet connection for seamless online activities during meetings' },
  { name: 'Projector', description: 'A device for projecting images onto a screen or wall' },
  { name: 'Whiteboard', description: 'A smooth, glossy surface for writing on with markers, typically used for presentations and brainstorming sessions' },
  { name: 'Video Conferencing', description: 'Equipment and software for conducting remote meetings with audio and video capabilities' },
  { name: 'Refreshments', description: 'Beverages and snacks provided for meeting attendees' },
  { name: 'Flipchart', description: 'A large pad of paper attached to a stand, used for presenting information or brainstorming ideas with markers' },
  { name: 'Comfortable Seating', description: 'Chairs designed for long periods of sitting, providing ergonomic support and comfort' },
  { name: 'Climate Control', description: 'Heating, ventilation, and air conditioning systems to maintain a comfortable temperature' }
]
facilities_data.each do |facility_data|
  Facility.find_or_create_by!(facility_data)
end

# Create departments if they don't exist
departments_data = [
  { name: 'Golden Owl Q3', description: 'The department at CMT-8 street', address: 'Level 7th, 538 Cach Mang Thang Tam, Ward 11, District 3, HCMC' },
  { name: 'Golden Owl Q2 - L1', description: 'The department at Sala', address: 'Level 1th, C00-13 Sarina Apartment, An Loi Dong Ward, Thu Duc City, HCMC' },
  { name: 'Golden Owl Q2 - L2', description: 'The department at Sala', address: 'Level 2th, C00-13 Sarina Apartment, An Loi Dong Ward, Thu Duc City, HCMC' },
  { name: 'Golden Owl Q2 - L3', description: 'The department at Sala', address: 'Level 3th, C00-13 Sarina Apartment, An Loi Dong Ward, Thu Duc City, HCMC' }
]
departments_data.each do |department_data|
  Department.find_or_create_by!(department_data)
end

# Create or find teams
teams_data = ['Ruby Alpha', 'Ruby Beta', 'L&D']
teams_data.each do |team_name|
  Team.find_or_create_by!(name: team_name)
end

# Create or find users
users_data = [
  { email: 'enzo.nguyen.gos@gmail.com', password: Devise.friendly_token[0, 20], teams: [Team.find_by_name('Ruby Alpha')] },
  { email: 'nducminh.it@gmail.com', password: '123123', roles: [admin_role], teams: [Team.find_by_name('Ruby Beta')] },
  { email: 'dev1.gos@gmail.com', password: '123123', teams: [Team.find_by_name('L&D')] },
  { email: 'dev2.gos@gmail.com', password: '123123', teams: [Team.find_by_name('Ruby Alpha')] }
]

users_data.each do |user_data|
  user = User.find_or_create_by!(email: user_data[:email]) do |u|
    u.password = user_data[:password]
    u.roles = user_data[:roles] || [user_role]
    u.teams = user_data[:teams]
  end
end

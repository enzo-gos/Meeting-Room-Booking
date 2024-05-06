# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

Role.create!(name: 'admin')
Role.create!(name: 'user')

Team.create!(name: 'Ruby Alpha')

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

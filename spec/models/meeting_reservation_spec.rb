# spec/models/meeting_reservation_spec.rb

require 'rails_helper'

RSpec.describe MeetingReservation, type: :model do
  let(:department) { Department.create!(name: 'Golden Owl Q3') } # Assuming Department model exists
  let(:facility) { Facility.create!(name: 'Lab') } # Assuming Facility model exists
  let(:room) { Room.create!(name: 'Conference Room', department_id: department.id, facility_ids: [facility.id], max_capacity: 10, preview_image: fixture_file_upload('spec/fixtures/images/room.jpg', 'image/jpeg')) } # Assuming Room model has a preview_image attachment
  let(:user) { User.new(email: 'user@example.com', password: 'password', provider: 'google', uid: '1234567890', current_password: 'password') }
  let(:user2) { User.new(email: 'user2@example.com', password: 'password', provider: 'google', uid: '1234567990', current_password: 'password') }

  let(:filter_title) { { 'title' => 'Strategy Meeting', 'book_by' => '', 'book_at' => '', 'start_time' => '', 'room_id' => '' } }
  let(:filter_book_by) { { 'title' => '', 'book_by' => user, 'book_at' => '', 'start_time' => '', 'room_id' => '' } }
  let(:filter_book_at) { { 'title' => '', 'book_by' => '', 'book_at' => Date.today, 'start_time' => '', 'room_id' => '' } }
  let(:filter_start_time) { { 'title' => '', 'book_by' => '', 'book_at' => '', 'start_time' => start_time, 'room_id' => '' } }
  let(:filter_room) { { 'title' => '', 'book_by' => '', 'book_at' => '', 'start_time' => '', 'room_id' => room.id } }
  let(:filter_all) { { 'title' => 'Strategy Meeting', 'book_by' => user, 'book_at' => Date.today, 'start_time' => start_time, 'room_id' => room.id } }

  let(:team) { Team.create!(name: 'L&D') }
  let(:start_time) { Time.now }
  let(:meeting_reservation) { MeetingReservation.create!(title: 'Strategy Meeting', room: room, book_by: user, members: [user2], team: team, book_at: Date.today, start_time: start_time, end_time: start_time + 1.hour) }
  let(:recurring_reservation) { MeetingReservation.create!(title: 'Recurring Meeting', room: room, book_by: user, members: [user2], team: team, book_at: Date.today, start_time: start_time, end_time: start_time + 1.hour, recurring: "{'validations':{'day':[5]},'rule_type':'IceCube::WeeklyRule','interval':1,'week_start':0}") }

  before do
    user.save!
    department.save!
    facility.save!
    room.save!
    meeting_reservation.save!
  end

  describe 'validations' do
    it 'validates presence of title' do
      meeting_reservation.title = nil
      expect(meeting_reservation).not_to be_valid
      expect(meeting_reservation.errors[:title]).to include('Title must be provided')
    end

    it 'validates presence of book_at' do
      meeting_reservation.book_at = nil
      expect(meeting_reservation).not_to be_valid
      expect(meeting_reservation.errors[:book_at]).to include('Book at must be provided')
    end

    it 'validates presence of start_time' do
      meeting_reservation.start_time = nil
      expect(meeting_reservation).not_to be_valid
      expect(meeting_reservation.errors[:start_time]).to include('Start time must be provided')
    end

    it 'validates presence of end_time' do
      meeting_reservation.end_time = nil
      expect(meeting_reservation).not_to be_valid
      expect(meeting_reservation.errors[:end_time]).to include('End time must be provided')
    end

    it 'validates start_time is less than end_time' do
      meeting_reservation.start_time = Time.now
      meeting_reservation.end_time = Time.now - 1.minute
      expect(meeting_reservation).not_to be_valid
      expect(meeting_reservation.errors[:start_time]).to include('Start time must be less than end time')
    end

    it 'validates time difference is at least 15 minutes' do
      meeting_reservation.start_time = Time.now
      meeting_reservation.end_time = Time.now + 14.minutes
      expect(meeting_reservation).not_to be_valid
      expect(meeting_reservation.errors[:base]).to include('The meeting must last at least 15 minutes from the start time.')
    end

    it 'validates invitation is required if no members and no team' do
      meeting_reservation.members.clear
      meeting_reservation.team = nil
      expect(meeting_reservation).not_to be_valid
      expect(meeting_reservation.errors[:base]).to include('Invitation must be included.')
    end
  end

  describe 'associations' do
    it 'belongs to a room' do
      expect(meeting_reservation.room).to eq(room)
    end

    it 'belongs to a book_by user' do
      expect(meeting_reservation.book_by).to eq(user)
    end

    it 'belongs to a team' do
      expect(meeting_reservation.team).to eq(team)
    end

    it 'has and belongs to many members' do
      expect(meeting_reservation.members).to include(user2)
    end
  end

  describe 'scopes' do
    it 'filters by title' do
      expect(MeetingReservation.filter(filter_title).count).to eq(1)
    end

    it 'filters by book_by' do
      expect(MeetingReservation.filter(filter_book_by).count).to eq(1)
    end

    it 'filters by start_time' do
      expect(MeetingReservation.filter(filter_start_time).count).to eq(1)
    end

    it 'filters by room' do
      expect(MeetingReservation.filter(filter_room).count).to eq(1)
    end

    it 'full filters' do
      expect(MeetingReservation.filter(filter_all).count).to eq(1)
    end
  end

  it 'adds an error if there is an overlapping single event' do
    # Create a single event that overlaps with the existing meeting
    overlapping_meeting = MeetingReservation.new(title: 'Overlapping Meeting', room: room, book_by: user, team: team, book_at: Date.today, start_time: start_time, end_time: start_time + 1.hour)

    overlapping_meeting.valid?
    expect(overlapping_meeting.errors[:base]).to include('A meeting has already been booked at this time.')
  end

  it 'adds an error if there is an overlapping recurring event' do
    # Create a recurring event that overlaps with the existing meeting
    # overlapping_meeting = MeetingReservation.create!(title: 'Overlapping Meeting', room: room, book_by: user, team: team, book_at: Date.today, start_time: Time.now + 30.minutes, end_time: Time.now + 1.hour + 30.minutes, recurring: { rule: 'FREQ=DAILY;COUNT=5', dtstart: '20230101T090000Z', dtend: '20230105T100000Z' })
    recurring_reservation.save!

    overlapping_meeting = MeetingReservation.new(title: 'Recurring Meeting', room: room, book_by: user, team: team, book_at: Date.today, start_time: start_time, end_time: start_time + 1.hour, recurring: "{'validations':{'day':[5]},'rule_type':'IceCube::WeeklyRule','interval':1,'week_start':0}")
    overlapping_meeting.valid?
    expect(overlapping_meeting.errors[:base]).to include('A meeting has already been booked at this time.')
  end
end

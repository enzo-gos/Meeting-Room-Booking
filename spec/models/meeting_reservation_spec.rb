# spec/models/meeting_reservation_spec.rb

require 'rails_helper'

RSpec.describe MeetingReservation, type: :model do
  let(:department) { create(:department) }
  let(:facility) { create(:facility) }

  let(:room) { create(:room, department: department, facilities: [facility]) }

  let(:user) { create(:user) }
  let(:user2) { create(:user) }
  let(:team) { create(:team) }

  let(:start_time) { (Time.now + 7.hours + 40.minutes).to_datetime }
  let(:meeting_reservation) { create(:meeting_reservation, title: 'Strategy Meeting', room: room, book_by: user, members: [user2], team: team, start_time: start_time, end_time: start_time + 1.hour) }

  before do
    department.save!
    facility.save!
    user.save!
    user2.save!
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
      meeting_reservation.start_time = start_time
      meeting_reservation.end_time = Time.now
      expect(meeting_reservation).not_to be_valid
      expect(meeting_reservation.errors[:start_time]).to include('Start time must be less than end time')
    end

    it 'validates time difference is at least 15 minutes' do
      meeting_reservation.start_time = start_time
      meeting_reservation.end_time = meeting_reservation.start_time + 14.minutes
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
      expect(ReservationsQuery.new.call({ 'title' => 'Strategy Meeting', 'book_by' => '', 'book_at' => '', 'start_time' => '', 'room_id' => '' }).count).to eq(1)
    end

    it 'filters by book_by' do
      expect(ReservationsQuery.new.call({ 'title' => '', 'book_by' => user, 'book_at' => '', 'start_time' => '', 'room_id' => '' }).count).to eq(1)
    end

    it 'filters by book_at' do
      expect(ReservationsQuery.new.call({ 'title' => '', 'book_by' => '', 'book_at' => Date.today, 'start_time' => '', 'room_id' => '' }).count).to eq(1)
    end

    it 'filters by start_time' do
      expect(ReservationsQuery.new.call({ 'title' => '', 'book_by' => '', 'book_at' => '', 'start_time' => start_time, 'room_id' => '' }).count).to eq(1)
    end

    it 'filters by room' do
      expect(ReservationsQuery.new.call({ 'title' => '', 'book_by' => '', 'book_at' => '', 'start_time' => '', 'room_id' => room.id }).count).to eq(1)
    end

    it 'full filters' do
      expect(ReservationsQuery.new.call({ 'title' => 'Strategy Meeting', 'book_by' => user, 'book_at' => Date.today, 'start_time' => start_time, 'room_id' => room.id }).count).to eq(1)
    end
  end

  it 'adds an error if there is an overlapping single event' do
    # Create a single event that overlaps with the existing meeting
    overlapping_meeting = build(:meeting_reservation, room: room, start_time: start_time, end_time: start_time + 1.hour)
    overlapping_meeting.valid?
    expect(overlapping_meeting.errors[:base]).to include('A meeting has already been booked at this time.')
  end

  it 'adds an error if there is an overlapping recurring event' do
    # Create a recurring event that overlaps with the existing meeting
    overlapping_meeting = build(:meeting_reservation, room: room, start_time: start_time, end_time: start_time + 1.hour, recurring: "{'validations':{'day':[5]},'rule_type':'IceCube::WeeklyRule','interval':1,'week_start':0}")
    overlapping_meeting.valid?
    expect(overlapping_meeting.errors[:base]).to include('A meeting has already been booked at this time.')
  end
end

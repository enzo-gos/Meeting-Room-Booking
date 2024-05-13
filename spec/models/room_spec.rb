# spec/models/room_spec.rb

require 'rails_helper'

RSpec.describe Room, type: :model do
  let(:department) { Department.create!(name: 'Engineering') } # Assuming Department model exists
  let(:facility) { Facility.create!(name: 'Lab') } # Assuming Facility model exists
  let(:filter_name) { { 'name' => 'Conference Room', 'department_id' => '', 'facility_ids' => '', 'min_capacity' => nil, 'max_capacity' => nil } }
  let(:filter_department) { { 'name' => '', 'department_id' => department.id, 'facility_ids' => '', 'min_capacity' => nil, 'max_capacity' => nil } }
  let(:filter_facility) { { 'name' => '', 'department_id' => '', 'facility_ids' => facility.id.to_s, 'min_capacity' => nil, 'max_capacity' => nil } }
  let(:filter_capacity) { { 'name' => '', 'department_id' => '', 'facility_ids' => '', 'min_capacity' => 10, 'max_capacity' => 20 } }
  let(:filter_all) { { 'name' => 'Conference Room', 'department_id' => department.id, 'facility_ids' => facility.id.to_s, 'min_capacity' => 10, 'max_capacity' => 20 } }
  let(:room) { Room.create!(name: 'Conference Room', department_id: department.id, facility_ids: [facility.id], max_capacity: 10, preview_image: fixture_file_upload('spec/fixtures/images/room.jpg', 'image/jpeg')) } # Assuming Room model has a preview_image attachment

  before do
    department.save!
    facility.save!
    room.save!
  end

  describe 'validations' do
    it 'validates presence of department_id' do
      room.department_id = nil
      expect(room).not_to be_valid
      expect(room.errors[:department_id]).to include('Department must be provided')
    end

    it 'validates presence of preview_image' do
      room.preview_image.purge
      expect(room).not_to be_valid
      expect(room.errors[:preview_image]).to include('Preview image must be provided')
    end

    it 'validates presence of name' do
      room.name = nil
      expect(room).not_to be_valid
      expect(room.errors[:name]).to include("Name can't be blank")
    end

    it 'validates presence of facility_ids' do
      room.facility_ids = []
      expect(room).not_to be_valid
      expect(room.errors[:facility_ids]).to include('Facilities must be included')
    end

    it 'validates max_capacity' do
      room.max_capacity = 2
      expect(room).not_to be_valid
      expect(room.errors[:max_capacity]).to include('Capacity must be between 3 and 200')

      room.max_capacity = 201
      expect(room).not_to be_valid
      expect(room.errors[:max_capacity]).to include('Capacity must be between 3 and 200')
    end

    it 'ensures name is unique per department' do
      duplicate_room = Room.new(name: room.name, department: department)
      duplicate_room.valid?
      expect(duplicate_room.errors[:name]).to include('A room with this name already exists in this department')
    end
  end

  describe 'associations' do
    it 'belongs to a department' do
      expect(room.department).to eq(department)
    end

    it 'has and belongs to many facilities' do
      expect(room.facilities).to include(facility)
    end
  end

  describe 'scopes' do
    it 'filters by name' do
      expect(Room.filter(filter_name).count).to eq(1)
    end

    it 'filters by department' do
      expect(Room.filter(filter_department).count).to eq(1)
    end

    it 'filters by facilities' do
      expect(Room.filter(filter_facility).count).to eq(1)
    end

    it 'filters by capacity' do
      expect(Room.filter(filter_capacity).count).to eq(1)
    end

    it 'full filters' do
      expect(Room.filter(filter_all).count).to eq(1)
    end
  end
end

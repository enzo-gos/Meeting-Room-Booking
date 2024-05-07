# == Schema Information
#
# Table name: rooms
#
#  id            :bigint           not null, primary key
#  name          :string
#  department_id :bigint           not null
#  max_capacity  :integer
#  description   :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class Room < ApplicationRecord
  FILTER_PARAMS = %i[name department_id facility_ids min_capacity max_capacity].freeze

  belongs_to :department
  has_and_belongs_to_many :facilities

  has_one_attached :preview_image

  scope :with_attached_preview_image, -> { includes(preview_image_attachment: :blob) }

  scope :by_name, ->(query) { where('rooms.name ilike ?', "%#{query}%") }
  scope :by_department, ->(department_id) { where(department_id: department_id) if department_id.present? }
  scope :by_facilities, ->(facility_ids) {
    if facility_ids.present?
      where('NOT EXISTS (
        SELECT id
        FROM unnest(ARRAY[?]) AS selected_facilities(facility_id)
        WHERE NOT EXISTS (
          SELECT id
          FROM facilities_rooms
          WHERE room_id = rooms.id
          AND facility_id = CAST(selected_facilities.facility_id AS bigint)
        )
      )', facility_ids.split(','))
    else
      all
    end
  }
  scope :by_capacity, ->(min_capacity, max_capacity) {
    query = all

    query = query.where('rooms.max_capacity >= ?', min_capacity) if min_capacity.present?
    query = query.where('rooms.max_capacity <= ?', max_capacity) if max_capacity.present?

    query
  }

  def self.filter(filters)
    Room
      .with_attached_preview_image
      .includes([:department, :facilities])
      .order(:id)
      .by_name(filters['name'])
      .by_department(filters['department_id'])
      .by_facilities(filters['facility_ids'])
      .by_capacity(filters['min_capacity'], filters['max_capacity'])
  end

  validates :department_id, presence: { message: 'Department must be provided' }
  validates :preview_image, presence: { message: 'Preview image must be provided' }
  validates :name, presence: { message: "Name can't be blank" }
  validates :facility_ids, presence: { message: 'Facilities must be included' }
  validates :max_capacity, presence: { message: 'Capacity must be provided' },
                           numericality: {
                             only_integer: true,
                             greater_than_or_equal_to: 3,
                             less_than_or_equal_to: 200,
                             message: 'Capacity must be between 3 and 200'
                           }
  validates :name, uniqueness: { scope: :department_id, message: 'A room with this name already exists in this department' }
end

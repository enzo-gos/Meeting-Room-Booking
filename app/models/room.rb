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
  belongs_to :department
  has_and_belongs_to_many :facilities
  has_one_attached :preview_image

  scope :with_attached_preview_image, -> { includes(preview_image_attachment: :blob) }

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

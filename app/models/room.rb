class Room < ApplicationRecord
  belongs_to :department
  has_and_belongs_to_many :facilities

  has_one_attached :preview_image

  validates :department_id, presence: true
  validates :preview_image, presence: true
  validates :name, presence: true
  validates :facility_ids, presence: true
  validates :max_capacity, presence: true
end

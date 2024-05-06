class MeetingReservation < ApplicationRecord
  has_rich_text :description
  has_rich_text :note

  belongs_to :room
  belongs_to :book_by, class_name: :User
  belongs_to :team, optional: true

  has_and_belongs_to_many :members, class_name: :User, join_table: :meeting_invitations, dependent: :destroy

  validates :title, presence: { message: 'Title must be provided' }
  validates :book_at, presence: { message: 'Book at must be provided' }
  validates :start_time, presence: { message: 'Start time must be provided' }
  validates :end_time, presence: { message: 'End time must be provided' }
  validates :member_ids, presence: { message: 'Members must be included' }
end

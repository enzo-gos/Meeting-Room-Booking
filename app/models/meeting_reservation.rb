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

  validate :does_not_conflict, if: -> { new_record? && !persisted? }
  validate :start_time_less_than_end_time
  validate :time_difference_is_15_minutes

  def does_not_conflict
    book_at_str = book_at ? book_at.strftime('%Y-%m-%d') : book_at
    overlapping_events = MeetingReservation.where('((start_time < ? AND end_time > ?) OR (start_time < ? AND end_time > ?)) AND book_at = ?', end_time, start_time, end_time, start_time, book_at_str)

    if overlapping_events.exists?
      errors.add(:base, 'A meeting has already been booked at this time.')
    end
  end

  def start_time_less_than_end_time
    if start_time && end_time && start_time >= end_time
      errors.add(:start_time, 'Start time must be less than end time')
    end
  end

  def time_difference_is_15_minutes
    if start_time && end_time && (end_time - start_time).to_i / 60.0 < 15
      errors.add(:base, 'The meeting must last at least 15 minutes from the start time.')
    end
  end
end

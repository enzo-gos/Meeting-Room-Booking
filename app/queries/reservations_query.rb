module ReservationScopes
  def by_title(query)
    return all unless query.present?
    where('meeting_reservations.title ilike ?', "%#{query}%")
  end

  def by_room(room_id)
    return all unless room_id.present?
    where(room_id: room_id)
  end

  def by_book_by(book_by_id)
    return all unless book_by_id.present?
    where(book_by_id: book_by_id)
  end

  def by_book_at(book_at)
    return all unless book_at.present?
    where(book_at: book_at).where(recurring: nil)
  end

  def by_start_time(start_time)
    return all unless start_time.present?
    where(start_time: start_time)
  end
end

class ReservationsQuery
  FILTER_PARAMS = %i[title book_at start_time room_id].freeze

  def initialize(meeting_reservation = MeetingReservation.with_room_department.order('created_at'))
    @meeting_reservation = meeting_reservation
  end

  def call(filters)
    @meeting_reservation
      .extending(ReservationScopes)
      .by_room(filters['room_id'])
      .by_title(filters['title'])
      .by_book_at(filters['book_at'])
      .by_start_time(filters['start_time'])
  end
end

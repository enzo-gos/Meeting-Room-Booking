module RoomScopes
  def by_name(query)
    return all unless query.present?
    where('rooms.name ilike ?', "%#{query}%")
  end

  def by_department(department_id)
    return all unless department_id.present?
    where(department_id: department_id)
  end

  def by_facilities(facility_ids)
    return all unless facility_ids.present?
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
  end

  def by_capacity(min_capacity, max_capacity)
    query = all

    query = query.where('rooms.max_capacity >= ?', min_capacity) if min_capacity.present?
    query = query.where('rooms.max_capacity <= ?', max_capacity) if max_capacity.present?

    query
  end
end

class RoomsQuery
  FILTER_PARAMS = %i[name department_id facility_ids min_capacity max_capacity].freeze

  def initialize(meeting_room = Room.includes([:department, :facilities]).with_attached_preview_image.order(:id))
    @meeting_room = meeting_room
  end

  def call(filters)
    @meeting_room
      .extending(RoomScopes)
      .by_name(filters['name'])
      .by_department(filters['department_id'])
      .by_facilities(filters['facility_ids'])
      .by_capacity(filters['min_capacity'], filters['max_capacity'])
  end
end

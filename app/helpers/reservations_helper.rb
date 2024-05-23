module ReservationsHelper
  def option_from_rule(meeting_reservation)
    return nil unless meeting_reservation.recurring?

    rule = RecurringSelect.dirty_hash_to_rule(meeting_reservation.ice_cube_rule)
    ar = [rule.to_s, rule.to_hash.to_json]

    ar[0] += '*'
    ar << { 'data-custom' => true }
    ar
  end
end

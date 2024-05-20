module MeetingRoomsHelper
  def determine_color(reservation, current_user)
    if reservation.book_by_id == current_user.id && !reservation.outdated
      'green'
    elsif reservation.book_by_id != current_user.id && !reservation.outdated
      'sky'
    else
      'grey'
    end
  end

  def determine_url(reservation, current_user)
    view_params = reservation.recurring? ? { id: reservation.id, recurring: reservation.start_datetime.to_i } : { id: reservation.id }
    if current_user.id == reservation.book_by_id && !reservation.outdated
      edit_reservation_path(view_params)
    else
      reservation_path(view_params)
    end
  end
end

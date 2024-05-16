class ReservationPolicy < ApplicationPolicy
  def update?
    record.book_by_id == user.id && !record.outdated
  end

  def destroy?
    record.book_by_id == user.id && !record.outdated
  end
end

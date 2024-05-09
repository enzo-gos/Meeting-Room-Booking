class ReservationPolicy < ApplicationPolicy
  def update?
    record.book_by_id == user.id
  end

  def destroy?
    record.book_by_id == user.id
  end
end

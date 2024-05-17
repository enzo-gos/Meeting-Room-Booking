module ReservationJobs
  extend ActiveSupport::Concern

  def schedule_job(reservation_id)
    find_sidekiq_job('ReservationScheduleJob', reservation_id)
  end

  def monthly_job(reservation_id)
    find_sidekiq_job('MonthlyBookJob', reservation_id)
  end
end

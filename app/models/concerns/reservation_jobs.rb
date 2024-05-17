module ReservationJobs
  extend ActiveSupport::Concern

  def schedule_job
    find_sidekiq_job('ReservationScheduleJob', id)
  end

  def monthly_job
    find_sidekiq_job('MonthlyBookJob', id)
  end
end

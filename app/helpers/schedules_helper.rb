module SchedulesHelper
  def self.next_month(from:)
    from + 1.month - 7.days
  end

  def find_sidekiq_job(*args)
    kclass = args.shift

    sidekiq = Sidekiq::ScheduledSet.new
    sidekiq.find { |schedule| schedule.klass == kclass && args.each_with_index.all? { |elem, index| schedule.args[index] == elem } }
  end
end

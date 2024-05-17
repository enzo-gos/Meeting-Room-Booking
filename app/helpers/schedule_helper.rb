module ScheduleHelper
  def find_sidekiq_job(*args)
    kclass = args.shift

    sidekiq = Sidekiq::ScheduledSet.new
    sidekiq.find { |schedule| schedule.klass == kclass && args.each_with_index.all? { |elem, index| schedule.args[index] == elem } }
  end
end

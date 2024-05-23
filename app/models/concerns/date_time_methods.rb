module DateTimeMethods
  extend ActiveSupport::Concern

  def build_datetime(date_time)
    DateTime.new(date_time.year, date_time.month, date_time.day, date_time.hour, date_time.min, date_time.sec, '+07:00')
  end

  def calculate_datetime(base_time, offset_time)
    base_time + offset_time.seconds_since_midnight.seconds
  end

  def iso_string(datetime)
    datetime.strftime('%Y-%m-%dT%H:%M:%S%:z')
  end
end

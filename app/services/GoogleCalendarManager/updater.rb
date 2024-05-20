module GoogleCalendarManager
  class Updater < ApplicationService
    def initialize(authorization:, event:)
      @authorization = authorization
      @event = event
      @event[:calendar_id] ||= 'primary'
      @event[:note] ||= ''
      @event[:members] ||= []
      @event[:recurrence] ||= []
    end

    def call
      update_event
    end

    private

    def update_event
      _client, service = Initializer.new(@authorization).call

      google_event = service.get_event(@event[:calendar_id], @event[:event_id])
      google_event.summary = @event[:title]
      google_event.description = @event[:note]
      google_event.start = Google::Apis::CalendarV3::EventDateTime.new(date_time: @event[:start_date], time_zone: 'Asia/Ho_Chi_Minh')
      google_event.end = Google::Apis::CalendarV3::EventDateTime.new(date_time: @event[:end_date], time_zone: 'Asia/Ho_Chi_Minh')
      google_event.attendees = @event[:members]
      google_event.recurrence = @event[:recurrence]

      service.update_event(@event[:calendar_id], google_event.id, google_event, send_updates: 'all')
    end
  end
end

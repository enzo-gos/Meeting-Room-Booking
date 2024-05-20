module GoogleCalendarManager
  class Creator < ApplicationService
    def initialize(authorization:, event:)
      @authorization = authorization
      @event = event
    end

    def call
      create_new_event
    end

    private

    def create_new_event
      _client, service = Initializer.new(@authorization).call

      google_event = Google::Apis::CalendarV3::Event.new(
        summary: @event[:title],
        description: @event[:note] || '',
        start: Google::Apis::CalendarV3::EventDateTime.new(
          date_time: @event[:start_date],
          time_zone: 'Asia/Ho_Chi_Minh'
        ),
        end: Google::Apis::CalendarV3::EventDateTime.new(
          date_time: @event[:end_date],
          time_zone: 'Asia/Ho_Chi_Minh'
        ),
        attendees: @event[:members],
        reminders: {
          use_default: false,
          overrides: [
            Google::Apis::CalendarV3::EventReminder.new(
              reminder_method: 'popup',
              minutes: @event[:reminder] || 30
            ),
            Google::Apis::CalendarV3::EventReminder.new(
              reminder_method: 'email',
              minutes: @event[:reminder] || 30
            )
          ]
        },
        recurrence: @event[:recurrence] || [],
        notification_settings: {
          notifications: [
            { type: 'event_creation', method: 'email' },
            { type: 'event_change', method: 'email' },
            { type: 'event_cancellation', method: 'email' },
            { type: 'event_response', method: 'email' }
          ]
        }
      )

      service.insert_event(@event[:calendar_id] || 'primary', google_event, send_updates: 'all')
    end
  end
end

module GoogleCalendar
  def initialize_client
    client = Signet::OAuth2::Client.new(client_options)
    client.update!(session[:authorization])
    client
  end

  def initialize_calendar_service
    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = initialize_client
    service
  end

  def client_options
    {
      client_id: ENV['GOOGLE_OAUTH_CLIENT_ID'],
      client_secret: ENV['GOOGLE_OAUTH_CLIENT_SECRET'],
      authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
      token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
      scope: Google::Apis::CalendarV3::AUTH_CALENDAR,
      redirect_uri: google_calendar_callback_url
    }
  end

  def create_new_event(title:, start_date:, end_date:, members:, note: '', recurrence: [], calendar_id: 'primary', reminder: 30)
    service = initialize_calendar_service

    event = Google::Apis::CalendarV3::Event.new(
      summary: title,
      description: note,
      start: Google::Apis::CalendarV3::EventDateTime.new(date_time: start_date, time_zone: 'Asia/Ho_Chi_Minh'),
      end: Google::Apis::CalendarV3::EventDateTime.new(date_time: end_date, time_zone: 'Asia/Ho_Chi_Minh'),
      attendees: members,
      reminders: {
        use_default: false,
        overrides: [
          Google::Apis::CalendarV3::EventReminder.new(reminder_method: 'popup', minutes: reminder),
          Google::Apis::CalendarV3::EventReminder.new(reminder_method: 'email', minutes: reminder)
        ]
      },
      recurrence: recurrence,
      notification_settings: {
        notifications: [
          { type: 'event_creation', method: 'email' },
          { type: 'event_change', method: 'email' },
          { type: 'event_cancellation', method: 'email' },
          { type: 'event_response', method: 'email' }
        ]
      }
    )

    service.insert_event(calendar_id, event, send_updates: 'all')
  end

  def update_event(event_id:, title:, start_date:, end_date:, members:, note: '', recurrence: [], calendar_id: 'primary')
    service = initialize_calendar_service

    event = service.get_event(calendar_id, event_id)

    event.summary = title
    event.description = note
    event.start = Google::Apis::CalendarV3::EventDateTime.new(date_time: start_date, time_zone: 'Asia/Ho_Chi_Minh')
    event.end = Google::Apis::CalendarV3::EventDateTime.new(date_time: end_date, time_zone: 'Asia/Ho_Chi_Minh')
    event.attendees = members
    event.recurrence = recurrence

    service.update_event(calendar_id, event.id, event, send_updates: 'all')
  end

  def delete_event(event_id:, calendar_id: 'primary')
    service = initialize_calendar_service
    service.delete_event(calendar_id, event_id, send_updates: 'all')
  end
end

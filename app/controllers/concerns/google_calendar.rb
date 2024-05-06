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
      client_id: ENV['GOOGLE_CLIENT_ID'],
      client_secret: ENV['GOOGLE_CLIENT_SECRET'],
      authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
      token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
      scope: Google::Apis::CalendarV3::AUTH_CALENDAR,
      redirect_uri: google_calendar_callback_url
    }
  end

  def create_new_event(title:, start_date:, end_date:, members:, note: '', calendar_id: 'primary', reminder: 30)
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
end

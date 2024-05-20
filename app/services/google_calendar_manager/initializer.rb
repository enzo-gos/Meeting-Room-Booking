module GoogleCalendarManager
  class Initializer < ApplicationService
    def initialize(authorization)
      @authorization = authorization
    end

    def call
      [initialize_client, initialize_calendar_service]
    end

    private

    def initialize_client
      client = Signet::OAuth2::Client.new(client_options)
      client.update!(@authorization)
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
        scope: Google::Apis::CalendarV3::AUTH_CALENDAR
      }
    end
  end
end

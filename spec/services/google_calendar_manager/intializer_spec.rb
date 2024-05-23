require 'rails_helper'

require 'google/apis/calendar_v3'
require 'signet/oauth_2/client'

RSpec.describe GoogleCalendarManager::Initializer do
  let(:client_options) do
    {
      client_id: 'test_client_id',
      client_secret: 'test_client_secret',
      authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
      token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
      scope: Google::Apis::CalendarV3::AUTH_CALENDAR
    }
  end

  let(:mock_oauth2_client) { instance_double(Signet::OAuth2::Client) }
  let(:mock_calendar_service) { instance_double(Google::Apis::CalendarV3::CalendarService) }
  let(:authorization) { 'mock_authorization_token' }

  before do
    allow(ENV).to receive(:[]).with('GOOGLE_OAUTH_CLIENT_ID').and_return('test_client_id')
    allow(ENV).to receive(:[]).with('GOOGLE_OAUTH_CLIENT_SECRET').and_return('test_client_secret')
  end

  describe '#initialize' do
    it 'initializes and updates the OAuth2 client' do
      allow(Signet::OAuth2::Client).to receive(:new).with(client_options).and_return(mock_oauth2_client)
      expect(mock_oauth2_client).to receive(:update!).with(authorization)

      allow(Signet::OAuth2::Client).to receive(:new).with(client_options).and_return(mock_oauth2_client)
      allow(mock_oauth2_client).to receive(:update!).with(authorization)
      allow(Google::Apis::CalendarV3::CalendarService).to receive(:new).and_return(mock_calendar_service)
      allow(mock_calendar_service).to receive(:authorization=).with(mock_oauth2_client)

      client, service = described_class.new(authorization).call

      expect(client).to eq(mock_oauth2_client)
      expect(service).to eq(mock_calendar_service)
    end
  end

  describe '#client_options' do
    it 'returns the correct client options' do
      options = client_options

      expect(options[:client_id]).to eq('test_client_id')
      expect(options[:client_secret]).to eq('test_client_secret')
      expect(options[:authorization_uri]).to eq('https://accounts.google.com/o/oauth2/auth')
      expect(options[:token_credential_uri]).to eq('https://accounts.google.com/o/oauth2/token')
      expect(options[:scope]).to eq(Google::Apis::CalendarV3::AUTH_CALENDAR)
    end
  end
end

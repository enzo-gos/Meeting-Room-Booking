require 'rails_helper'

RSpec.describe 'EventCreator' do
  let(:mock_authorization) { 'mock_authorization_token' }
  let(:mock_event) do
    {
      title: 'Test Error',
      note: "<div class=\"trix-content\">\n  <div>You're warmly invited to a meeting at <strong>Meeting Room 1 - Level 7th, 538 Cach Mang Thang Tam, Ward 11, District 3, HCMC</strong>.<br><br>Your input is highly appreciated, so please mark your calendar and endeavor to arrive on time.</div>\n</div>\n",
      start_date: DateTime.new(2024, 5, 23, 13, 30, 0),
      end_date: DateTime.new(2024, 5, 23, 16, 30, 0),
      members: [
        Google::Apis::CalendarV3::EventAttendee.new(email: 'enzo.nguyen.gos@gmail.com', response_status: 'needsAction')
      ],
      reminder: 30
    }
  end

  let(:mock_service) { instance_double(Google::Apis::CalendarV3::CalendarService) }
  let(:mock_client) { instance_double(Signet::OAuth2::Client) }
  let(:mock_initializer) { instance_double(GoogleCalendarManager::Initializer, call: [mock_client, mock_service]) }
  let(:event_creator) { GoogleCalendarManager::Creator.new(authorization: mock_authorization, event: mock_event) }

  describe '#call' do
    it 'creates a new event' do
      allow(GoogleCalendarManager::Initializer).to receive(:new).with(mock_authorization).and_return(mock_initializer)
      allow(mock_service).to receive(:insert_event)

      event_creator.call

      expect(mock_service).to have_received(:insert_event).with('primary', an_instance_of(Google::Apis::CalendarV3::Event), send_updates: 'all')
    end
  end
end

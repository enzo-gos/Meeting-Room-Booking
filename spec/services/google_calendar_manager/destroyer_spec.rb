require 'rails_helper'

RSpec.describe 'Destroyer' do
  let(:mock_authorization) { 'mock_authorization_token' }
  let(:mock_event) { { event_id: 'mock_event_id' } }
  let(:mock_client) { instance_double(Signet::OAuth2::Client) }
  let(:mock_service) { instance_double(Google::Apis::CalendarV3::CalendarService) }
  let(:mock_initializer) { instance_double(GoogleCalendarManager::Initializer, call: [mock_client, mock_service]) }
  let(:destroyer) { GoogleCalendarManager::Destroyer.new(authorization: mock_authorization, event: mock_event) }

  describe '#call' do
    it 'deletes the specified event' do
      allow(GoogleCalendarManager::Initializer).to receive(:new).with(mock_authorization).and_return(mock_initializer)
      allow(mock_service).to receive(:delete_event)

      destroyer.call

      expect(mock_service).to have_received(:delete_event).with('primary', 'mock_event_id', send_updates: 'all')
    end
  end
end

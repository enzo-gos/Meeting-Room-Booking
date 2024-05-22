RSpec.describe 'Updater' do
  let(:mock_authorization) { 'mock_authorization_token' }
  let(:mock_event) do
    {
      event_id: 'mock_event_id',
      title: 'Updated Event Title',
      note: 'Updated Event Note',
      start_date: DateTime.new(2024, 5, 23, 13, 30, 0),
      end_date: DateTime.new(2024, 5, 23, 16, 30, 0),
      members: [
        Google::Apis::CalendarV3::EventAttendee.new(email: 'enzo.nguyen.gos@gmail.com', response_status: 'needsAction')
      ],
      recurrence: ['RRULE:FREQ=DAILY;COUNT=2']
    }
  end

  let(:mock_service) { instance_double(Google::Apis::CalendarV3::CalendarService) }
  let(:mock_client) { instance_double(Signet::OAuth2::Client) }
  let(:mock_initializer) { instance_double(GoogleCalendarManager::Initializer, call: [mock_client, mock_service]) }
  let(:updater) { GoogleCalendarManager::Updater.new(authorization: mock_authorization, event: mock_event) }

  describe '#call' do
    it 'updates the specified event' do
      allow(GoogleCalendarManager::Initializer).to receive(:new).with(mock_authorization).and_return(mock_initializer)
      allow(mock_service).to receive(:get_event).and_return(Google::Apis::CalendarV3::Event.new)
      allow(mock_service).to receive(:update_event)

      updater.call

      expect(mock_service).to have_received(:update_event)
    end
  end
end

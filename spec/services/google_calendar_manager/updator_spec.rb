RSpec.describe GoogleCalendarManager::Updater do
  let(:mock_authorization) { 'mock_authorization_token' }
  let(:start_time) { DateTime.current + 1.day }
  let(:end_time) { start_time + 1.hour }
  let(:mock_event) do
    {
      event_id: Faker::Alphanumeric.alphanumeric(number: 10),
      title: Faker::Lorem.sentence(word_count: 3),
      note: Faker::Lorem.paragraph(sentence_count: 2),
      start_date: start_time,
      end_date: end_time,
      members: [
        Google::Apis::CalendarV3::EventAttendee.new(email: Faker::Internet.email(name: 'Enzo Nguyen'), response_status: 'needsAction'),
        Google::Apis::CalendarV3::EventAttendee.new(email: Faker::Internet.email(name: 'User1 Tran'), response_status: 'needsAction')
      ],
      recurrence: ['RRULE:FREQ=DAILY;COUNT=2']
    }
  end

  let(:mock_service) { instance_double(Google::Apis::CalendarV3::CalendarService) }
  let(:mock_client) { instance_double(Signet::OAuth2::Client) }
  let(:mock_initializer) { instance_double(GoogleCalendarManager::Initializer, call: [mock_client, mock_service]) }
  let(:updater) { described_class.new(authorization: mock_authorization, event: mock_event) }

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

module GoogleCalendarManager
  class Destroyer < ApplicationService
    def initialize(authorization:, event:)
      @authorization = authorization
      @event = event
      @event[:calendar_id] ||= 'primary'
    end

    def call
      delete_event
    end

    private

    def delete_event
      _client, service = Initializer.new(@authorization).call
      service.delete_event(@event[:calendar_id], @event[:event_id], send_updates: 'all')
    end
  end
end

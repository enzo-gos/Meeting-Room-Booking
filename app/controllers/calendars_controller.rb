# app/controllers/calendars_controller.rb
class CalendarsController < ApplicationController
  include GoogleCalendar

  def redirect
    client = initialize_client
    redirect_to client.authorization_uri.to_s, allow_other_host: true
  end

  def callback
    client = initialize_client
    client.code = params[:code]
    response = client.fetch_access_token!
    session[:authorization] = response
    redirect_to session[:calendar_callback_url]
  end
end

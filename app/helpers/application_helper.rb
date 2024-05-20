module ApplicationHelper
  include Pagy::Frontend

  def current_controller?(names)
    names.include?(params[:controller]) unless params[:controller].blank?
  end

  def format_datetime(datetime)
    datetime.strftime('%Y-%m-%d %H:%M:%S')
  end
end

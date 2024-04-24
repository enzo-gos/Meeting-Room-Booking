module ApplicationHelper
  include Pagy::Frontend

  def current_controller?(names)
    names.include?(params[:controller]) unless params[:controller].blank?
  end
end

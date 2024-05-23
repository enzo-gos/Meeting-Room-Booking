module Filterable
  def filter!(resource)
    store_filters(resource)
    [session["#{resource.to_s.underscore}_filters"], apply_filters(resource)]
  end

  private

  def store_filters(resource)
    session["#{resource.to_s.underscore}_filters"] = {} unless session.key?("#{resource.to_s.underscore}_filters")

    session["#{resource.to_s.underscore}_filters"].merge!(filter_params_for(resource))
  end

  def filter_params_for(resource)
    filter_params = params.transform_values { |value| value.is_a?(Array) ? value.reject(&:empty?).join(',') : value }
    filter_params.permit(resource.class.const_get(:FILTER_PARAMS))
  end

  def apply_filters(resource)
    resource.call(session["#{resource.to_s.underscore}_filters"])
  end
end

module ApplicationHelper
  def navbar_link_to(name, controller, action, url_options = {}, link_options = {})
    active = 'active' if params[:controller] == controller.to_s && params[:action] == action.to_s
    content_tag(:li, class: (active if active)) do
      link_to(name, url_for(url_options.merge(controller: controller, action: action)), link_options)
    end
  end
end

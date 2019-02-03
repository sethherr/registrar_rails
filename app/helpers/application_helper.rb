# frozen_string_literal: true

module ApplicationHelper
  def main_container_class
    @fluid_container ? "container-fluid" : "container"
  end

  def page_title
    return @page_title if @page_title
    [
      (in_admin? ? "Admin" : "Registrar"),
      default_action_name_title,
      controller_title_for_action
    ].compact.join(" ")
  end

  def in_admin?
    controller_namespace == "admin"
  end

  def active_link(link_text, link_path, html_options = {})
    match_controller = html_options.delete(:match_controller)
    html_options[:class] ||= ""
    html_options[:class] += " active" if current_page_active?(link_path, match_controller)
    link_to(raw(link_text), link_path, html_options).html_safe
  end

  def current_page_active?(link_path, match_controller = false)
    link_path = Rails.application.routes.recognize_path(link_path)
    active_path = Rails.application.routes.recognize_path(request.url)
    matches_controller = active_path[:controller] == link_path[:controller]
    return true if match_controller && matches_controller
    current_page?(link_path) || matches_controller && active_path[:action] == link_path[:action]
  rescue # This mainly fails in testing - but why not rescue always
    false
  end

  def sortable(column, title = nil, html_options = {})
    title ||= column.gsub(/_(id|at)\z/, "").titleize
    html_options[:class] = "#{html_options[:class]} sortable-link"
    direction = column == sort_column && sort_direction == "desc" ? "asc" : "desc"
    if column == sort_column
      html_options[:class] += " active"
      span_content = direction == "asc" ? "\u2193" : "\u2191"
    end
    link_to(sortable_search_params.merge(sort: column, direction: direction, query: params[:query]), html_options) do
      concat(title.html_safe)
      concat(content_tag(:span, span_content, class: "sortable-direction"))
    end
  end

  def sortable_search_params
    search_param_keys = params.keys.select { |k| k.to_s.match(/\Asearch_/) }
    params.permit(:direction, :sort, :user_id, *search_param_keys)
  end

  def sortable_search_params_without_sort
    sortable_search_params.except(:direction, :sort)
  end

  def page_id
    @page_id ||= [controller_namespace, controller_name].compact.join("_")
  end

  def controller_namespace
    @controller_namespace ||= (self.class.parent.name != "Object") ? self.class.parent.name.downcase : nil
  end

  # Refactor this bullshit
  def bootstrap_devise_error_messages!
    return "" if resource.errors.empty?

    messages = resource.errors.full_messages.map { |message| content_tag(:li, message) }.join
    sentence = I18n.t(
      "errors.messages.not_saved",
      count: resource.errors.count,
      resource: resource.class.model_name.human.downcase
    )

    html = <<-HTML
    <div class="alert alert-danger">
      <button type="button" class="close" data-dismiss="alert" aria-label="Close">
        <span aria-hidden="true">&times;</span>
      </button>
      <h4 class="alert-heading">#{sentence}</h4>
      <ul class="mb-0">#{messages}</ul>
    </div>
    HTML

    html.html_safe
  end

  private

  def default_action_name_title
    return "Display" if action_name == "show"
    action_name == "index" ? "All" : action_name.titleize
  end

  def controller_title_for_action
    return controller_name.titleize if %(index).include?(action_name)
    controller_name.singularize.titleize
  end
end

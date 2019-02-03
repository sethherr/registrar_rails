class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :enable_rack_profiler

  def append_info_to_payload(payload)
    super
    payload[:ip] = request.env["HTTP_CF_CONNECTING_IP"]
  end

  def enable_rack_profiler
    return true unless current_user&.developer?
    Rack::MiniProfiler.authorize_request unless Rails.env.test?
  end

  def after_sign_in_path_for(resource)
    request.env["omniauth.origin"] || stored_location_for(resource) || user_root_path
  end

  def after_sign_up_path_for(resource)
    after_sign_in_path_for(resource)
  end

  def after_sign_out_path_for(resource)
    root_url
  end

  helper_method :user_root_path, :controller_namespace,

  def user_root_path
    return root_url unless current_user.present?
    account_path
  end

  def controller_namespace
    @controller_namespace ||= (self.class.parent.name != "Object") ? self.class.parent.name.downcase : nil
  end
end

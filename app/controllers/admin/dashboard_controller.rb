# frozen_string_literal: true

class Admin::DashboardController < Admin::BaseController
  def clear_cache
    Rails.cache.clear
    flash[:success] = "Cache cleared!"
    redirect_to user_root_path
  end
end

# frozen_string_literal: true

class Admin::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin!

  helper_method :user_root_path, :user_subject

  def user_root_path
    if current_user.present?
      if current_user.admin?
        admin_users_path
      else
        root_path
      end
    else
      new_user_session_path
    end
  end

  def user_subject
    return @user_subject if defined?(@user_subject)
    @user_subject = params[:user_id].present? && User.where(id: params[:user_id]).first
  end

  def ensure_admin!
    return true if current_user&.admin?
    flash[:error] = "You don't have access to that page!"
    redirect_to user_root_path
    return
  end
end

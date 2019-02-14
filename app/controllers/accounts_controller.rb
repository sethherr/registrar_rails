# frozen_string_literal: true

class AccountsController < ApplicationController
  before_action :redirect_to_signup_unless_user_present!

  def show
    @page_title = "GlobaliD Registrar Account"
    @registrations = current_user.current_registrations
  end

  def edit; end

  def update
    @user.attributes = permitted_params
    if @user.errors.blank? && @user.save
      flash[:success] = "Updated account successfully"
      redirect_to account_path
    else
      render :edit
    end
  end

  private

  def redirect_to_signup_unless_user_present!
    if current_user.present?
      @user = current_user
      return true
    end
    redirect_to new_user_session_path
    return
  end

  def permitted_params
    params.require(:user).permit(:name)
  end
end

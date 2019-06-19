# frozen_string_literal: true

class RegistrationLogsController < ApplicationController
  before_action :redirect_to_signup_unless_user_present!
  before_action :find_registration, except: %i[index show]
  before_action :authorize_registration_for_user!, except: %i[index show]

  def index
    redirect_to user_root_path and return
  end

  def show
    redirect_to user_root_path and return
  end

  def new
    @registration_log ||= RegistrationLog.new(registration_id: @registration.id)
  end

  def create
    @registration_log = RegistrationLog.new(permitted_params)
    if @registration_log.save
      flash[:success] = "Recorded registration log"
      redirect_to registration_path(@registration.to_param)
    else
      flash[:error] = "Unable to record registration log"
      render :new
    end
  end

  private

  def permitted_params
    params.require(:registration_log).permit(:information, :user_description, :kind)
          .merge(authorizer: "authorizer_owner", user: current_user, registration_id: @registration.id)
  end

  def find_registration
    @registration ||= available_registrations.friendly_find(params.dig(:registration_log, :registration_id) || params[:registration_id])
  end

  def available_registrations
    current_user.present? ? current_user.registrations : Registration.where(id: nil)
  end

  def authorize_registration_for_user!
    return true if @registration.present? && @registration.current_owner == current_user
    flash[:error] = "You are not the owner of that registration!"
    redirect_to user_root_path
    return
  end
end

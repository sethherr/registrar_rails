# frozen_string_literal: true

class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :ensure_user!, raise: false

  def bike_index
    @user = UserIntegration.user_from_omniauth(current_user&.id,
                                               "bike_index",
                                               request.env["omniauth.auth"].uid,
                                               request.env["omniauth.auth"])
    if @user.persisted?
      sign_in_and_redirect @user
      flash[:success] = "Logged in with Bike Index" if is_navigational_format?
    else
      flash[:error] = "We're sorry, we failed to sign you in. Please contact support@globalidregistrar.net"
      redirect_to root_url
    end
  end
end

# frozen_string_literal: true

class RegistrationsController < ApplicationController
  before_action :redirect_to_signup_unless_user_present!, except: %i[index show]
  before_action :find_registration, except: %i[index new create]
  before_action :authorize_registration_for_user!, except: %i[index new create]

  def index
    page = params[:page] || 1
    per_page = params[:per_page] || 100
    @registrations = available_registrations.reorder(created_at: :desc).page(page).per(per_page)
  end

  def show
    @registration_logs = @registration.registration_logs.reorder(created_at: :desc)
  end

  def new
    @registration ||= Registration.new(status: "registered")
  end

  def create
    @registration = Registration.new(permitted_params)
    if @registration.save
      Ownership.create_for(@registration, creator: current_user, owner: current_user)
      @registration.reload
      flash[:success] = "Created new registration"
      redirect_to registration_path(@registration.to_param)
    else
      flash[:error] = "Unable to create registration"
      render :new
    end
  end

  def edit; end

  def update
    if @registration.update(permitted_params)
      if new_owner_params[:new_owner].present?
        @registration.transfer_ownership(creator: current_user,
                                         new_owner: new_owner_params[:new_owner],
                                         new_owner_kind: new_owner_params[:new_owner_kind])
        flash[:success] = "Registration sent to #{new_owner_params[:new_owner]}"
        redirect_to account_path
      else
        flash[:success] = "Registration updated"
        redirect_to registration_path(@registration)
      end
    else
      render :edit
    end
  end

  private

  def permitted_params
    params.require(:registration).permit(:title, :description, :main_category_tag,
                                         :manufacturer_tag, :tags_list, :status)
          .merge(non_empty_image_params)
  end

  def non_empty_image_params
    # Recreate the public images attributes, but without empty images
    return {} unless permitted_images_hash.present?
    {
      registration_images_attributes: permitted_images_hash[:public_images_attributes]
        .select { |_k, v| v[:image].present? || v[:id].present? }
    }
  end

  def new_owner_params
    params.require(:registration).permit(:new_owner, :new_owner_kind)
  end

  def find_registration
    @registration ||= available_registrations.friendly_find(params[:id])
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

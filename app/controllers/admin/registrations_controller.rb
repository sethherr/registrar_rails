# frozen_string_literal: true

class Admin::RegistrationsController < Admin::BaseController
  include SortableTable
  before_action :find_registration, except: [:index]

  def index
    page = params[:page] || 1
    per_page = params[:per_page] || 100
    @registrations = Registration.includes(:current_owner).reorder("#{sort_column} #{sort_direction}").page(page).per(per_page)
  end

  def show; end

  private

  def sortable_columns
    %w[created_at email name]
  end

  def find_registration
    @registration = Registration.where(id: params[:id]).first
    raise ActiveRecord::RecordNotFound unless @registration.present?
  end
end

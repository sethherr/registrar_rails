# frozen_string_literal: true

class Admin::UsersController < Admin::BaseController
  include SortableTable
  before_action :find_user, except: [:index]

  def index
    page = params[:page] || 1
    per_page = params[:per_page] || 100
    @admins_only = params[:admins].present?
    users = @admins_only ? User.employee : User
    users = users.admin_search(params[:search_query]) if params[:search_query].present?
    @users = users.reorder("#{sort_column} #{sort_direction}").page(page).per(per_page)
  end

  def show; end

  def edit; end

  def update
    if @user.update(permitted_params)
      flash[:success] = "User updated" unless flash[:error].present?
      redirect_to admin_users_path
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    flash[:success] = "User removed"
    redirect_to admin_users_path
  end

  private

  def sortable_columns
    %w[created_at email name]
  end

  def permitted_params
    params.require(:user).permit(:manually_confirm, :name, :admin_role)
  end

  def find_user
    @user = User.where(id: params[:id]).first
    raise ActiveRecord::RecordNotFound unless @user.present?
  end
end

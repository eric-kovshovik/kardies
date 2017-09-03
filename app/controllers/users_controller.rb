class UsersController < ApplicationController
  before_action :set_user, except: [:index]

  def index
    if search_present?
      @users ||= get_all_indexed_users
      @search ||= search_criteria
    else
      @users ||= get_all_users
      @search ||= search_criteria
    end
  end

  def show
    user_deleted_check
  end

  private

  def set_user
    @user = User.find_by(username: params[:username])
    rescue_error unless @user
  end

  def search_criteria
    search_present? ? last_search : SearchCriterium.new
  end

  def search_present?
    current_user.search_criteria.present?
  end

  def get_all_users
    User.all_except(current_user)
        .includes(:user_detail)
        .not_blocked
        .order(created_at: :desc)
        .page params[:page]
  end

  def get_all_indexed_users
     User.search(last_search)
         .page params[:page]
  end

  def last_search
    current_user.search_criteria.last
  end
end

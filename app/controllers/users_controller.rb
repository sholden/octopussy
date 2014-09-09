class UsersController < ApplicationController
  def search
    @users = User.elastic_shart_search params[:q]
    respond_to do |format|
      format.json { render json: @users.map(&:search_data) }
      format.html
    end

  end
end
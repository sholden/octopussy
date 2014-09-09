class VehiclesController < ApplicationController
  before_filter :require_authentication

  def index
    get_user
    @vehicles = @user.vehicles
  end

  def show
    get_user
    @vehicle = @user.vehicles.find(params[:id])
  end

  private

  def get_user
    @user = current_user

    if params[:user_id]
      replicated_user = ReplicatedUser.find!(params[:user_id])
      @user = Sharting.using(replicated_user.current_shard) { User.find_by_email(params[:user_id]) }
    end
  end
end
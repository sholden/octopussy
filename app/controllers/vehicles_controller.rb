class VehiclesController < ApplicationController
  before_filter :require_authentication

  def index
    @vehicles = current_user.vehicles
  end

  def show
    @vehicle = Vehicle.find(params[:id])
  end
end
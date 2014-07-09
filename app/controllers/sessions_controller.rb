class SessionsController < ApplicationController
  def create
    self.current_user = Sharting.using_key(params[:user_email]) do
      User.authenticate(params[:user_email], params[:password])
    end

    flash[:error] = 'Invalid login' unless logged_in?
    require_authentication
    session[:user_email] = current_user.email

    respond_to do |format|
      format.json { render json: session_json, status: :created }
      format.all { redirect_to root_path }
    end
  end

  def destroy
    self.current_user = nil
    session[:user_email] = nil

    respond_to do |format|
      format.html { redirect_to new_session_path }
      format.all { render nothing: true, status: :no_content }
    end
  end
end
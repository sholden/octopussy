class SessionsController < ApplicationController
  def create
    self.current_user = Authenticator.authenticate(params[:user_email], params[:password])

    flash[:error] = 'Invalid login' unless logged_in?
    require_authentication
    session[:token] = AuthenticationToken.build(self.current_user)

    respond_to do |format|
      format.json { render json: session_json, status: :created }
      format.all { redirect_to root_path }
    end
  end

  def destroy
    self.current_user = nil
    session[:token] = nil

    respond_to do |format|
      format.html { redirect_to new_session_path }
      format.all { render nothing: true, status: :no_content }
    end
  end
end
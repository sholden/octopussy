module Api
  class UsersController < Api::Base
    def show
      user = Sharting.using_key(params[:user_email]) { User.find_by_email!(params[:user_email]) }

      respond_to do |format|
        format.json { render json: user.to_json }
      end
    end
  end
end
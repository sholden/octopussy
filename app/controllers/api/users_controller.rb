module Api
  class UsersController < Api::Base
    def show
      user = Sharting.using_key(params[:id]) { User.find_by_email!(params[:id]) }

      respond_to do |format|
        format.json { render json: {user: user, shard: Sharting.shard_for_key(user.email)} }
      end
    end
  end
end
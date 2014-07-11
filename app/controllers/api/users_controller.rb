module Api
  class UsersController < Api::Base
    def show
      replicated_user = ReplicatedUser.find(params[:id])
      user = replicated_user && Sharting.using(replicated_user.current_shard) do
        User.find_by_email!(replicated_user.email)
      end

      raise ActiveRecord::RecordNotFound unless user

      respond_to do |format|
        format.json { render json: {user: user, shard: user.current_shard} }
      end
    end
  end
end
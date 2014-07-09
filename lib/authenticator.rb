module Authenticator
  def self.authenticate(user_email, password)
    replicated_user = ReplicatedUser.find(user_email)
    return nil unless replicated_user

    Sharting.using(replicated_user.current_shard) do
      User.authenticate(user_email, password)
    end
  end
end
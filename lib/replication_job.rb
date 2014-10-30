class ReplicationJob
  include Sidekiq::Worker

  def perform(email, current_shard = 'master')
    Sharting.using(current_shard) do
      user = User.find_by_email(email)
      if user
        ReplicatedUser.replicate(user)
      else
        ReplicatedUser.find(email).try(:destroy)
      end
    end
  end
end
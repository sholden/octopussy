class ReplicatedUser < HateBase::Base
  self.table = :users

  column :email,            type: :string,  key: true
  column :id,               type: :integer, family: :data
  column :crypted_password, type: :string,  family: :data
  column :current_shard,    type: :string,  family: :data

  def self.replicate(user)
    if user.send("#{key_column}_changed?")
      old_key = user.send("#{key_column}_was")
      old_replicant = find(old_key)
      old_replicant.destroy if old_replicant
    end

    attributes = Hash[columns.keys.map{|k| [k, user.send(k).to_s]}]
    create(attributes)
  end
end
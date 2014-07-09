class ReplicatedUser < HateBase::Base
  self.table = :users

  column :email,            type: :string,  key: true
  column :id,               type: :integer, family: :data
  column :crypted_password, type: :string,  family: :data
  column :current_shard,    type: :string,  family: :data

  def self.replicate(user)
    attributes = Hash[columns.keys.map{|k| [k, user.send(k).to_s]}]
    create(attributes)
  end
end
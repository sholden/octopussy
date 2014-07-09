class ReplicatedUser < HateBase::Base
  self.table = :users

  column :email,            type: :string,  key: true
  column :id,               type: :integer, family: :data
  column :crypted_password, type: :string,  family: :data
  column :current_shard,    type: :string,  family: :data

  def self.replicate(user)
    create!(user.attributes.slice(*columns.keys.map(&:to_s)))
  end
end

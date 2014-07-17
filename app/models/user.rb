class User < ActiveRecord::Base
  include Sharting::Identification
  include Sharting::ElasticShart

  has_many :vehicles, dependent: :destroy

  after_save    :replicate_to_hbase, unless: :destroyed?
  after_touch   :replicate_to_hbase, unless: :destroyed?
  after_destroy :remove_from_hbase

  searchkick

  def self.authenticate(email, password)
    User.find_by_email_and_crypted_password(email, encrypt_password(password))
  end

  def self.encrypt_password(password)
    Digest::SHA2.hexdigest(password)
  end

  def password=(password)
    self.crypted_password = self.class.encrypt_password(password)
  end

  def replicate_to_hbase
    ReplicatedUser.replicate(self)
  end

  def remove_from_hbase
    replicated = ReplicatedUser.find(email)
    replicated.destroy
  end

  def serializable_hash(*)
    super.merge(vehicles: vehicles.includes(:prices, :options).map(&:serializable_hash))
  end

  def search_data
    {id: id.to_s, name: name, email: email, current_shard: current_shard}
  end
end

class User < ActiveRecord::Base
  include Sharting::Identification

  has_many :vehicles, dependent: :destroy

  after_save :replicate_to_hbase

  def self.authenticate(email, password)
    hbase_user = ReplicatedUser.find(email)  rescue nil
    if hbase_user && hbase_user.crypted_password == encrypt_password(password)
      {id: hbase_user.sharded_id.to_i}
    else
      nil
    end
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

  def serializable_hash(*)
    super.merge(vehicles: vehicles.includes(:prices, :options).map(&:serializable_hash))
  end
end

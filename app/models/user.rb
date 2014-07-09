class User < ActiveRecord::Base
  include Sharting::Identification

  has_many :vehicles, dependent: :destroy

  after_create :replicate_to_hbase

  def self.authenticate(email, password)
    hbase_user = HbaseUser.find(email)  rescue nil
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
    [id,email].each {|key|
      HbaseUser.create(key.to_s,{:name => "data:sharded_id", :value =>"#{id}" })
      HbaseUser.create(key.to_s,{:name => "data:email", :value =>"#{email}" })
      HbaseUser.create(key.to_s,{:name => "data:crypted_password", :value =>"#{crypted_password}" })
    }
  end

  def serializable_hash(*)
    super.merge(vehicles: vehicles.includes(:prices, :options).map(&:serializable_hash))
  end
end

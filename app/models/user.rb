class User < ActiveRecord::Base
  include Sharting::Identification

  has_many :vehicles

  after_create :hbase_stuff
  attr_accessor :password

  def self.authenticate(email, password)
    User.find_by_email_and_crypted_password(email, encrypt_password(password))
  end

  def self.encrypt_password(password)
    Digest::SHA2.hexdigest(password)
  end

  def password=(password)
    self.crypted_password = self.class.encrypt_password(password)
  end


  def hbase_stuff
    [id,email].each {|key|
      HbaseUser.create(key.to_s,{:name => "data:sharded_id", :value =>"#{id}" })
      HbaseUser.create(key.to_s,{:name => "data:email", :value =>"#{email}" })
      HbaseUser.create(key.to_s,{:name => "data:crypted_password", :value =>"#{crypted_password}" })
    }

  end
end

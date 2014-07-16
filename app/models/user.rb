class User < ActiveRecord::Base
  include Sharting::Identification
  searchkick word_start: [:name]
  def search_data
    as_json only: [:name]
  end

  has_many :vehicles, dependent: :destroy

  after_save    :replicate_to_hbase, unless: :destroyed?
  after_touch   :replicate_to_hbase, unless: :destroyed?
  after_destroy :remove_from_hbase

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
end

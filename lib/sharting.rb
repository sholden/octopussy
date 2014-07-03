module Sharting


  def self.enabled?
    Octopus.enabled?
  end

  def self.key(key, &block)
    using(shard_for_key(key), &block)
  end

  def self.shard_for_key(key)
    :"shard_#{shard_number(key)}"
  end

  def self.shard_number(key)
    shard_number = Digest::SHA1.hexdigest(key).to_i(16) % number_of_shards
  end

  def self.using(shard, &block)
    Octopus.using(shard, &block)
  end

  def self.shards
    connection_proxy = ActiveRecord::Base.connection
    connection_proxy.instance_variable_get(:@shards)
  end

  def self.shard_names
    shards.keys.map(&:to_sym)
  end

  def self.database_name(shard_name)
    connection_proxy = ActiveRecord::Base.connection
    connection_proxy.send(:database_name, shard_name)
  end

  def self.number_of_shards
    Rails.configuration.number_of_shards
  end

  def self.generate_uid(key)
    key(key) do
      sql = "select shard_nextval() as next_seq, now_msec() as msec"
      next_seq, msec = ActiveRecord::Base.connection.execute(sql).first

      uid = msec << (64-41)
      uid |= shard_number(key) << (64-41-13)
      uid |= next_seq
    end
  end
end
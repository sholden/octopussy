module Sharting
  SHARD_COUNT = 4

  def self.enabled?
    Octopus.enabled?
  end

  def self.key(key, &block)
    using(shard_for_key(key), &block)
  end

  def self.shard_for_key(key)
    shard_number = Digest::SHA2.hexdigest(key).to_i(16) % SHARD_COUNT
    :"shard_#{shard_number}"
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
end
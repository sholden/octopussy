module Sharting
  def self.enabled?
    Octopus.enabled?
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

  def database_name(shard_name)
    connection_proxy = ActiveRecord::Base.connection
    connection_proxy.send(:database_name, shard_name)
  end
end
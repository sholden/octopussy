module Sharting
  extend Enumerable

  def self.enabled?
    Octopus.enabled?
  end

  def self.using_key(key, &block)
    older_key = self.current_key

    begin
      self.current_key = key
      using(shard_name(calculate_shard_number(key)), &block)
    ensure
      self.current_key = older_key
    end
  end

  def self.current_shard
    Octopus.current_shard
  end

  def self.current_key
    Thread.current['sharting.current_key']
  end

  def self.current_key=(key)
    Thread.current['sharting.current_key'] = key
  end

  def self.current_shard_number
    shard_number_for_shard(current_shard)
  end

  def self.shard_number_for_shard(shard_name)
    slave_shard_names.index(shard_name)
  end

  def self.shard_for_key(key)
    shard_name(calculate_shard_number(key))
  end

  def self.shard_name(shard_number)
    :"shard_#{shard_number}"
  end

  def self.calculate_shard_number(key)
    Digest::SHA1.hexdigest(key).to_i(16) % number_of_shards
  end

  def self.using(shard, &block)
    Octopus.using(shard, &block)
  end

  def self.each(using: shard_names)
    if block_given?
      Array(using).each do |shard_name|
        using(shard_name) do
          yield shard_name
        end
      end
    else
      to_enum(:each)
    end
  end

  def self.shards
    connection_proxy = ActiveRecord::Base.connection
    connection_proxy.instance_variable_get(:@shards)
  end

  def self.shard_names
    shards.keys.map(&:to_sym)
  end

  def self.slave_shard_names
    (shard_names - [:master])
  end

  def self.database_name(shard_name)
    connection_proxy = ActiveRecord::Base.connection
    connection_proxy.send(:database_name, shard_name)
  end

  def self.number_of_shards
    Rails.configuration.number_of_shards
  end

  def self.generate_uid(shard_name = nil)
    shard_name ||= current_shard
    raise 'No shard specified!' unless shard_name
    using(shard_name) do
      sql = 'select shard_nextval() as next_seq, now_msec() as msec'
      next_seq, msec = ActiveRecord::Base.connection.execute(sql).first

      uid = msec.to_i << (64-41)
      uid |= shard_number_for_shard(shard_name) << (64-41-13)
      uid | next_seq
    end
  end
end
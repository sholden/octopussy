module Sharting
  extend Enumerable

  def self.enabled?
    Octopus.enabled?
  end

  def self.using_key(key, &block)
    older_key = self.current_key
    older_shard_number = self.current_shard_number

    begin
      self.current_key = key
      self.current_shard_number = shard_number(key)
      using(shard_name(self.current_shard_number), &block)
    ensure
      self.current_key = older_key
      self.current_shard_number = older_shard_number
    end
  end

  def self.current_key
    Thread.current['sharting.current_key']
  end

  def self.current_key=(key)
    Thread.current['sharting.current_key'] = key
  end

  def self.current_shard_number
    Thread.current['sharting.current_shard_number']
  end

  def self.current_shard_number=(shard_number)
    Thread.current['sharting.current_shard_number'] = shard_number
  end

  def self.shard_for_key(key)
    shard_name(shard_number(key))
  end

  def self.shard_name(shard_number)
    :"shard_#{shard_number}"
  end

  def self.shard_number(key)
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

  def self.database_name(shard_name)
    connection_proxy = ActiveRecord::Base.connection
    connection_proxy.send(:database_name, shard_name)
  end

  def self.number_of_shards
    Rails.configuration.number_of_shards
  end

  def self.next_seq_modulus
    1024
  end

  def self.generate_uid
    raise 'Not on a shard!' unless current_shard_number
    sql = 'select shard_nextval() as next_seq, now_msec() as msec'
    next_seq, msec = ActiveRecord::Base.connection.execute(sql).first
    uid = msec.to_i << (64-41)
    uid |= current_shard_number << (64-41-13)
    uid | (next_seq % next_seq_modulus)
  end
end

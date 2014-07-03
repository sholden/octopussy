class User < ActiveRecord::Base
  has_many :vehicles

  def generate_sharded_id
    Sharting.key(email) do

    end

    sql = "select shard_nextval() as next_seq, now_msec() as msec"
    next_seq, msec = connection.execute(sql).first

    Sharting.shard_for_key(email) % Sharting.number_of_shards
    msec = connection.execute("select now_ddmsec() as msec").entries.first.first.to_i
    uid = msec << (64-41)
    uid |= shard_id << (64-41-13)
    uid |= next_seq
    self.sharded_id = uid
  end
end

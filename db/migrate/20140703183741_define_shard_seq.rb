class DefineShardSeq < ActiveRecord::Migration
  using(*Sharting.shard_names)

  def build_client
    config = connection.pool.spec.config.slice(:username, :password, :host, :port, :database)
    config[:database] ||= Sharting.database_name(Thread.current["octopus.current_shard"] || :master)
    config[:flags] = Mysql2::Client::MULTI_STATEMENTS | Mysql2::Client::FOUND_ROWS
    Mysql2::Client.new(config)
  end

  def up
    sql = <<-SQL
      drop table if exists shard_seq_tbl;
      create table shard_seq_tbl ( nextval bigint not null primary key auto_increment ) engine = MyISAM;
      alter table shard_seq_tbl AUTO_INCREMENT = 10000;
      drop function if exists shard_nextval;
      create function shard_nextval()
      returns bigint
      begin
        insert into shard_seq_tbl values (NULL) ;
        set @R_ObjectId_val=LAST_INSERT_ID() ;
        delete from shard_seq_tbl ;
        return @R_ObjectId_val ;
      end;
      drop function if exists now_msec;
      CREATE FUNCTION now_msec RETURNS STRING SONAME "now_msec.so";
    SQL

    build_client.query(sql)
  end

  def down
    sql = <<-SQL
      drop table if exists shard_seq_tbl;
      drop function if exists shard_nextval;
      drop function if exists now_msec;
    SQL

    build_client.query(sql)
  end
end

namespace :db do
  namespace :shards do
    desc 'Create shard databases'
    task :create => :environment do
      if Sharting.enabled?
        Sharting.shards.except(:master).each do |shard_name, connection_pool|
          connection_pool.connection.create_database(Sharting.database_name(shard_name))
        end
      end
    end

    task :drop => :environment do
      if Sharting.enabled?
        Sharting.shards.except(:master).each do |shard_name, connection_pool|
          connection_pool.connection.drop_database(Sharting.database_name(shard_name))
        end
      end
    end
  end
end
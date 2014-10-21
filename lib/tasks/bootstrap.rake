require 'pathname'
require 'fileutils'

namespace :bootstrap do
  task :run do
    run
  end

  task :install => [
    :prepare_database,
    :prepare_hbase,
    :load_data
  ]

  task :prepare_database do
    Process.wait(fork { exec('rake db:create')})
    Process.wait(fork { exec('rake db:shards:create')})
    Process.wait(fork { exec('rake db:migrate')})
  end

  task :load_data => :environment do
    loader = DataLoader.new(Rails.root.join('db', 'data.tar.gz'))
    loader.load!
  end

  task :prepare_hbase => :environment do
    HateBase::Base.connection.create_table('users', 'data')
  end
end


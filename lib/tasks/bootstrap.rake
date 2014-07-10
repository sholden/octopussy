require 'pathname'

namespace :bootstrap do
  task :install => [:install_hbase, :prepare_database] do

  end

  task :install_hbase do
    install_hbase
    configure_hbase
    create_hbase_table
  end

  task :prepare_database do
    #Rake::Task['db:shards:drop'].invoke
    #Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke rescue nil
    Rake::Task['db:shards:create'].invoke rescue nil
    Rake::Task['db:migrate'].invoke
  end

  def install_hbase(logger = Logger.new(STDOUT))
    target_path = Pathname.new(Dir.pwd).join('vendor')
    hbase_url = "http://mirrors.sonic.net/apache/hbase/hbase-0.98.3/hbase-0.98.3-hadoop2-bin.tar.gz"
    logger.info "Downloading and extracting Hbase to #{target_path}"
    `curl #{hbase_url} | (cd #{target_path}; tar -xzf -)`
  end

  def configure_hbase(logger = Logger.new(STDOUT))
    hbase_path = Pathname.new(Dir.pwd).join('vendor', 'hbase-0.98.3-hadoop2')
    config_xml = <<-XML
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
  <property>
    <name>hbase.rootdir</name>
    <value>file://#{hbase_path.join('data')}</value>
  </property>
  <property>
    <name>hbase.zookeeper.property.dataDir</name>
    <value>#{hbase_path.join('zookeeper')}</value>
  </property>
</configuration>
    XML
    logger.info "Writing hbase-site.xml:\n#{config_xml}"
    File.open(hbase_path.join('conf', 'hbase-site.xml').to_s, 'w'){|f| f.write config_xml }
  end

  def create_hbase_table(logger = Logger.new(STDOUT))
    hbase_bin = Pathname.new(Dir.pwd).join('vendor', 'hbase-0.98.3-hadoop2', 'bin', 'hbase')
    logger.info "Creating users table in hbase"
    puts `echo "create 'users', 'data' | #{hbase_bin} shell"`
  end
end
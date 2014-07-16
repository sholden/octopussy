require 'pathname'
require 'fileutils'
namespace :bootstrap do
  task :run do
    run
  end

  task :install => [
    :install_hbase,
    :prepare_database,
    :load_data
  ]

  task :install_hbase do
    install_hbase
  end

  task :prepare_database do
    #Process.wait(fork { exec('mysql.server stop')})
    #Process.wait(fork { exec('bin/mk-now-msec.sh')})
    #Process.wait(fork { exec('mysql.server stop')})
    #Process.wait(fork { exec('mysql.server start')})
    Process.wait(fork { exec('rake db:create')})
    Process.wait(fork { exec('rake db:shards:create')})
    Process.wait(fork { exec('rake db:migrate')})
  end

  task :load_data => :environment do
    run_hbase do
      loader = DataLoader.new(Rails.root.join('db', 'data.tar.gz'))
      loader.load!
    end
  end

  def run(logger = Logger.new(STDOUT))
    logger.info "Starting application..."
    run_hbase(logger) do
      run_server(logger) do
        logger.info "Application is running. CTRL-C to stop..."
        running = true
        trap('INT') { running = false }
        while running
          sleep 1
        end
        logger.info "Shutting down..."
      end
    end
  end

  def run_hbase(logger = Logger.new(STDOUT), check_install: true)
    if check_install && !File.exist?(hbase_installed_path)
      logger.error "Hbase not installed"
      return
    end
    hbase_start = hbase_path.join('bin', 'start-hbase.sh')
    hbase_stop = hbase_path.join('bin', 'stop-hbase.sh')
    hbase_bin = hbase_path.join('bin', 'hbase')

    logger.info "Starting Hbase..."
    Process.wait(fork { exec(hbase_start.to_s) })

    logger.info "Starting Hbase REST api..."
    hbase_rest_pid = fork { exec("#{hbase_bin} rest start")}

    yield if block_given?

    logger.info "Stopping Hbase REST api..."
    Process.kill('INT', hbase_rest_pid)
    Process.wait(hbase_rest_pid)

    logger.info "Stopping Hbase..."
    Process.wait(fork { exec(hbase_stop.to_s) })
  end

  def run_server(logger = Logger.new(STDOUT))
    rails_server = 'rails s'

    logger.info "Starting Octopussy Server..."
    octopussy_pid = fork { exec("#{rails_server}") }

    yield if block_given?

    logger.info "Stopping Octopussy Server..."
    Process.kill('INT', octopussy_pid)
    Process.wait(octopussy_pid)
  end

  def install_hbase(logger = Logger.new(STDOUT))
    return if File.exist?(hbase_installed_path.to_s)
    extract_hbase(logger)
    configure_hbase(logger)
    run_hbase(check_install: false) { create_hbase_table(logger) }
    FileUtils.touch(hbase_installed_path.to_s)
  end

  def hbase_path
    Pathname.new(Dir.pwd).join('vendor', 'hbase-0.98.3-hadoop2')
  end

  def hbase_installed_path
    hbase_path.join('OCTOPUSSY_INSTALLED')
  end

  def extract_hbase(logger = Logger.new(STDOUT))
    target_path = Pathname.new(Dir.pwd).join('vendor')
    hbase_url = "http://mirrors.sonic.net/apache/hbase/hbase-0.98.3/hbase-0.98.3-hadoop2-bin.tar.gz"
    logger.info "Downloading and extracting Hbase to #{target_path}"
    `curl #{hbase_url} | (cd #{target_path}; tar -xzf -)`
  end

  def configure_hbase(logger = Logger.new(STDOUT))
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
    hbase_bin = hbase_path.join('bin', 'hbase')
    hbase_migration = Pathname.new(Dir.pwd).join('db', 'hbase_schema.rb')
    logger.info "Creating users table in hbase"

    Process.wait(fork do
      Dir.chdir(hbase_path.to_s) do
        ENV.delete('RUBYOPT')
        exec("#{hbase_bin} shell #{hbase_migration}")
      end
    end)
  end
end


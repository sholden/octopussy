config = YAML.load(File.read(Rails.root.join('config', 'hbase.yml'))) rescue {}
HateBase::Base.establish_connection (config[Rails.env.to_s] || {}).symbolize_keys
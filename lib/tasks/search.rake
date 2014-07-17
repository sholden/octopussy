namespace :search do
  task :reindex => :environment do
    User.elastic_shart_reindex
  end
end
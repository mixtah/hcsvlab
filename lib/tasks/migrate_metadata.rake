require File.dirname(__FILE__) + '/migrate_metadata_helper.rb'

namespace :collection do
  desc " Migrate existing collection metadata from file (.n3) to DB"
  task :migrate_metadata => :environment do
    migrate_metadata_n3
  end
end
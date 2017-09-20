require File.dirname(__FILE__) + '/migrate_metadata_helper.rb'

namespace :collection do
  desc " Migrate existing collection metadata from file (.n3) to DB"
  task :migrate_metadata => :environment do
    # collect .n3 file from multiple directory
    files = []
    dirs = ["/data/collections/*.n3", "/mnt/volume/alveo-production-data/*.n3"]
    dirs.each do |dir|
      files += Dir[dir]
    end
    migrate_metadata_n3(files)

  end
end
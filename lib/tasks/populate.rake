require File.dirname(__FILE__) + '/sample_data_populator.rb'
begin
  namespace :db do
    desc "Populate the database with some sample data for testing"
    task :populate => :environment do
      # NEVER run in production
      puts "checking current environment...#{Rails.env}"
      if Rails.env.production?
        puts "NEVER run data populator in #{Rails.env}!"
      else
        puts "fine, go ahead."
        populate_data
      end
    end
  end
rescue LoadError
  puts "It looks like some Gems are missing: please run bundle install"
end
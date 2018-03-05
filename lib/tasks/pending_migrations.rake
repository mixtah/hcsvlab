require File.dirname(__FILE__) + '/pending_migrations.rb'
begin
  namespace :db do

    desc "Show pending migrations"
    task :cat_pending_migrations => :environment do
      cat_pending_migrations
    end

  end
end

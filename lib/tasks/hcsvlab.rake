# Override the default jettywrapper tasks for clean and config
tasks = Rake.application.instance_variable_get '@tasks'
tasks.delete 'jetty:clean'
tasks.delete 'jetty:config'
tasks.delete 'jetty:start'

namespace :jetty do

  namespace :hcsvlab do
    desc "Start background services"
    task :start_services => :environment do
      start_services
    end

    desc "Stop background services"
    task :stop_services => :environment do
      stop_services
    end

    desc "Restart background services"
    task :restart_services => :environment do
      stop_services
      start_services
    end
  end

  namespace :hcsvlab_test do

    desc "Start background services in test mode"
    task :start_services => :environment do
      start_services(true)
    end

    desc "Stop background services in test mode"
    task :stop_services => :environment do
      stop_services(true)
    end

    desc "Restart background services in test mode"
    task :restart_services => :environment do
      stop_services(true)
      start_services(true)
    end
  end

  #
  #
  #
  def start_services(test_mode = false)
    extra_arg = (test_mode)? "RAILS_ENV=test" : ""

    if (ENV['ACTIVEMQ_HOME'].present?)
      system("$ACTIVEMQ_HOME/bin/activemq start")
    else
      puts "ERROR: ACTIVEMQ_HOME environment variable is not defined. You will have to start activemq manually and the run this command again.".red
    end
    system("#{extra_arg} bundle exec rake jetty:start")
    system("#{extra_arg} bundle exec rake a13g:start_pollers")
  end

  #
  #
  #
  def stop_services(test_mode = false)
    extra_arg = (test_mode)? "RAILS_ENV=test" : ""

    system("#{extra_arg} bundle exec rake a13g:stop_pollers")
    system("#{extra_arg} bundle exec rake jetty:stop")

    if (ENV['ACTIVEMQ_HOME'].present?)
      system("$ACTIVEMQ_HOME/bin/activemq stop")
    else
      puts "ERROR: ACTIVEMQ_HOME environment variable is not defined. You will have to stop activemq manually.".red
    end
  end
end

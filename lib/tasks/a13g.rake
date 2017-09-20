namespace :a13g do

  desc "Start Solr workers"
  task :start_pollers => [:environment, :republish_dlq] do
    puts "Starting Solr Worker"
    system "nice -n 19  script/poller start -- process-group=solr_group"
  end

  desc "Stop Sol1 workers"
  task :stop_pollers => :environment do
    puts "Stopping Solr Worker"
    system "nice -n 19  script/poller stop -- process-group=solr_group"
  end

  desc "Republish dead letter queue from workers"
  task :republish_dlq => :environment do
    puts "Republishing Dead Letter Queue"

    STOMP_CONFIG = YAML.load_file("#{Rails.root.to_s}/config/broker.yml")[Rails.env] unless defined? STOMP_CONFIG

    stomp_client = Stomp::Client.open "#{STOMP_CONFIG['adapter']}://#{STOMP_CONFIG['host']}:#{STOMP_CONFIG['port']}"
    stomp_client.subscribe('alveo.solr.worker.dlq', {ack: :client}) do |msg|
      stomp_client.publish('alveo.solr.worker', msg.body)
      stomp_client.acknowledge(msg)
    end
  end

end

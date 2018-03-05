require File.dirname(__FILE__) + '/fedora_helper.rb'

namespace :fedora do

  @solr = RSolr.connect(Blacklight.solr_config)

  #
  # Ingest one metadata file, given as an argument
  #
  desc "Ingest one metadata file"
  task :ingest_one, [:corpus_rdf] => :environment do |t, args|
    corpus_rdf = args.corpus_rdf
    ingest_one(File.dirname(corpus_rdf), corpus_rdf)
  end

  #
  # Clear everything out of the system
  #
  desc "Clear out all data from the system"
  task :clear => :environment do

    logger.info "rake fedora:clear"

    Document.delete_all
    Item.delete_all
    Collection.delete_all
    CollectionList.delete_all

    # clear Solr
    uri = URI.parse(Blacklight.solr_config[:url] + '/update?commit=true')

    req = Net::HTTP::Post.new(uri)
    req.body = '<delete><query>*:*</query></delete>'

    req.content_type = "text/xml; charset=utf-8"
    req.body.force_encoding("UTF-8")
    res = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(req)
    end

    # Clear Sesame
    server = RDF::Sesame::Server.new(SESAME_CONFIG["url"].to_s)
    repositories = server.repositories
    repositories.each_key do |repositoryName|
      unless "SYSTEM".eql?(repositoryName)
        server.delete(repositories[repositoryName].path)
      end
    end
  end

  #
  # Clear one corpus (given as corpus=<corpus-name>) out of the system
  #
  desc "Clear a single corpus from the system"
  task :clear_corpus => :environment do

    corpus = ENV['corpus']

    if corpus.nil?
      puts "Usage: rake fedora:clear_corpus corpus=<corpus name>"
      exit 1
    end

    logger.info "rake fedora:clear_corpus corpus=#{corpus}"

    collection = Collection.find_by_name(corpus)
    Item.where(collection_id: collection).delete_all
    collection.try(:destroy)

    # clear Solr
    uri = URI.parse(Blacklight.solr_config[:url] + '/update?commit=true')

    req = Net::HTTP::Post.new(uri)
    req.body = "<delete><query>collection_name_facet:#{corpus}</query></delete>"

    req.content_type = "text/xml; charset=utf-8"
    req.body.force_encoding("UTF-8")
    res = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(req)
    end

    # Clear all metadata and annotations from the triple store
    server = RDF::Sesame::Server.new(SESAME_CONFIG["url"].to_s)
    repository = server.repository(corpus)
    repository.clear if repository.present?
  end

  #
  # Reindex one corpus (given as corpus=<corpus-name>)
  #
  desc "Re-index a single corpus"
  task :reindex_corpus => :environment do

    STOMP_CONFIG = YAML.load_file("#{Rails.root.to_s}/config/broker.yml")[Rails.env] unless defined? STOMP_CONFIG

    corpus = ENV['corpus']
    if corpus.nil?
      puts "Usage: rake fedora:reindex_corpus corpus=<corpus name>"
      exit 1
    end

    logger.info "rake fedora:reindex_corpus corpus=#{corpus}"

    items = Collection.find_by_name(corpus).items.pluck(:id)

    count = items.count
    logger.info "Reindexing #{count} items"

    stomp_client = Stomp::Client.open "#{STOMP_CONFIG['adapter']}://#{STOMP_CONFIG['host']}:#{STOMP_CONFIG['port']}"

    items.each_with_index do |item_id,i|
      print "Indexing #{i+1}/#{count}\r"
      reindex_item_to_solr(item_id, stomp_client)
    end
    puts "Published #{count} index messages to ActiveMQ"

    stomp_client.close

  end

  # Consolidate cores by indexing unindexed items
  #
  BATCH_SIZE = 5000
  desc "Run indexing for un-indexed items"
  task :consolidate => :environment do

    STOMP_CONFIG = YAML.load_file("#{Rails.root.to_s}/config/broker.yml")[Rails.env] unless defined? STOMP_CONFIG

    corpus = ENV['corpus']
    if corpus
      query = Item.where(collection_id: Collection.find_by_name(corpus)).unindexed
    else
      query = Item.unindexed
    end

    count = query.count
    logger.info "Indexing all #{count} #{corpus} items"
    # solr_worker = Solr_Worker.new
    stomp_client = Stomp::Client.open "#{STOMP_CONFIG['adapter']}://#{STOMP_CONFIG['host']}:#{STOMP_CONFIG['port']}"

    i = 1
    query.select(:id).find_each(:batch_size => BATCH_SIZE) do |item|
      print "Indexing #{i}/#{count}\r"
      # solr_worker.on_message("index #{item.id}")
      reindex_item_to_solr(item.id, stomp_client)
      i += 1
    end
    puts "Published #{count} index messages to ActiveMQ"
    stomp_client.close

  end

  #
  # Reindex the whole blinkin' lot
  #
  desc "Re-index all items in the system"
  task :reindex_all => :environment do
    
    logger.info "rake fedora:reindex_all"

    STOMP_CONFIG = YAML.load_file("#{Rails.root.to_s}/config/broker.yml")[Rails.env] unless defined? STOMP_CONFIG

    count = Item.count
    logger.info "Reindexing all #{count} Items"

    # solr_worker = Solr_Worker.new
    stomp_client = Stomp::Client.open "#{STOMP_CONFIG['adapter']}://#{STOMP_CONFIG['host']}:#{STOMP_CONFIG['port']}"
    i = 1
    Item.select(:id).find_each(:batch_size => BATCH_SIZE) do |item|
      print "Indexing #{i}/#{count}\r"
      # solr_worker.on_message("index #{item.id}")
      reindex_item_to_solr(item.id, stomp_client)
      i += 1
    end
    puts "Published #{count} index messages to ActiveMQ"
    stomp_client.close

  end

  #
  # Ingest and create default set of licenses
  #
  desc "Ingest licenses"
  task :ingest_licences => :environment do
    logger.info "rake fedora:ingest_licences"
    create_default_licences
  end

  desc "Ingest collection metadata"
  task :ingest_collection_metadata => :environment do
    dir = ENV['dir'] unless ENV['dir'].nil?

    if (dir.nil?) || (!Dir.exists?(dir))
      if dir.nil?
        puts "No directory specified."
      else
        puts "Directory #{dir} does not exist."
      end
      puts "Usage: rake fedora:ingest_collection_metadata dir=<folder>"
      exit 1
    end

    logger.info "rake fedora:ingest_collection_metadata dir=#{dir}"

    Dir.glob(dir + '/**/*.n3') { |n3|
      coll_name = File.basename(n3, ".n3")
      create_collection_from_file(n3, coll_name)
    }
  end

  #
  # Set up the default CollectionLists and License assignments
  #
  desc "Set up default collection lists and license assignments"
  task :collection_setup => :environment do
    logger.info "rake fedora:collection_setup"

    licences = {}
    Licence.all.each { |licence|
      licences[licence.name] = licence
    }

    setup_collection_list("AUSNC", licences["AusNC Terms of Use"],
                          "ace", "art", "austlit", "braidedchannels", "cooee", "gcsause", "ice", "mitcheldelbridge", "monash")
    Collection.assign_licence("austalk", licences["AusTalk Terms of Use"])
    Collection.assign_licence("avozes", licences["AVOZES Non-commercial (Academic) Licence"])
    Collection.assign_licence("clueweb", licences["ClueWeb Terms of Use"])
    Collection.assign_licence("pixar", licences["Creative Commons v3.0 BY-NC-SA"])
    Collection.assign_licence("rirusyd", licences["Creative Commons v3.0 BY-NC-SA"])
    Collection.assign_licence("mbep", licences["Creative Commons v3.0 BY-NC-SA"])
    Collection.assign_licence("jakartan_indonesian", licences["Creative Commons v3.0 BY-NC-SA"])
    Collection.assign_licence("llc", licences["LLC Terms of Use"])
  end

  desc "Clear Paradisec collections"
  task :paradisec_clear => :environment do
    collection_list = CollectionList.find_by_name("PARADISEC")
    collection_list.collections.each do |coll|
      logger.info "Clearing metadata for PARADISEC Collection #{coll.name} (#{coll.uri})"
      clear_collection_metadata(coll.name)
    end
  end

  #
  # Check a corpus directory, given as an argument
  #
  desc "Check one corpus directory"
  task :check => :environment do

    corpus_dir = ENV['corpus'] unless ENV['corpus'].nil?

    if (corpus_dir.nil?) || (!Dir.exists?(corpus_dir))
      if corpus_dir.nil?
        puts "No corpus directory specified."
      else
        puts "Corpus directory #{corpus_dir} does not exist."
      end
      puts "Usage: rake fedora:check corpus=<corpus folder>"
      exit 1
    end

    logger.info "rake fedora:check corpus=#{corpus_dir}"
    check_corpus(corpus_dir)
  end

  #
  # Create a manifest for a collection outlining the collection name, item ids and document metadata
  #
  desc "Create manifest for a collection"
  task :create_collection_manifest => :environment do
    corpus_dir = ENV['corpus'] unless ENV['corpus'].nil?

    if (corpus_dir.nil?) || (!Dir.exists?(corpus_dir))
      if corpus_dir.nil?
        puts "No corpus directory specified."
      else
        puts "Corpus directory #{corpus_dir} does not exist."
      end
      puts "Usage: rake fedora:create_collection_manifest corpus=<corpus folder>"
      exit 1
    end

    logger.info "rake fedora:create_collection_manifest corpus=#{corpus_dir}"
    create_collection_manifest(corpus_dir)
  end
end

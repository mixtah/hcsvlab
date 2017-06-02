#
# Import metadata from .n3 file to DB.
#
# .n3 file located in config.api_collections_location
#
#

def migrate_metadata_n3
  logger.debug "seed_metadata_n3: start"

  path = File.join(Rails.application.config.api_collections_location, "*.n3").to_s
  files = Dir[path]

  count = 0

  files.each do |file|
    logger.info "processing file[#{file}]..."
    graph = RDF::Graph.load(file, :format => :ttl)

    collection_name = File.basename(file, ".*")

    collection = Collection.find_by_name(collection_name)

    if collection.nil?
      logger.error "collection[#{collection_name}] not exist, stop processing file[#{file}]."
      next
    end

    MetadataHelper::update_rdf_graph(collection_name, graph)

    logger.info "file[#{file}] finished."

    count += 1
  end

  logger.info "total files found/finished [#{files.size}/#{count}]."

  logger.debug "seed_metadata_n3: end"
end
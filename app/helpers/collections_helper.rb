require "#{Rails.root}/lib/rdf-sesame/hcsvlab_server.rb"
require Rails.root.join('lib/tasks/fedora_helper.rb')

module CollectionsHelper

  # To check whether user is the owner of specific collection
  def self::is_owner(user, collection)
    logger.debug "is_owner: start - user[#{user}], collection[#{collection}]"
    rlt = false

    if collection.nil?
    # collection is nil, no one is the owner
    else
      if user.nil?
      #   user is nil, nil user is not the owner
      else
        if collection.owner.id == user.id || user.is_superuser?
          rlt = true
        end
      end
    end

    logger.debug "is_owner: end - rlt[#{rlt}]"

    rlt
  end

  #
  # Core functionality common to add document ingest (via api and web app)
  #
  def self.add_document_core(collection, item, document_metadata, document_filename)
    doc_id, msg = create_document(item, document_metadata)
    add_and_index_document(item, document_metadata)
    "Added the document #{File.basename(document_filename)} to item #{item.get_name} in collection #{collection.name}"

    # check contribution mapping
    if !document_metadata["alveo:Contribution"].nil? && !doc_id.nil?
      logger.debug "add_document_core: create contribution_mapping between contribution[#{document_metadata["alveo:Contribution"]}] and document[#{doc_id}]"
      # create association between contribution and document
      contrib_mapping = ContributionMapping.new
      contrib_mapping.contribution_id = document_metadata["alveo:Contribution"]
      contrib_mapping.item_id = item.id
      contrib_mapping.document_id = doc_id

      contrib_mapping.save!
    end
  end

  # Creates a document in the database from Json-ld document metadata
  #
  # Return:
  #
  # - document id (nil if failed)
  # - message (if created successfully nil, otherwise error message)
  def self.create_document(item, document_json_ld)

    expanded_metadata = JSON::LD::API.expand(document_json_ld).first

    uri = expanded_metadata[MetadataHelper::SOURCE.to_s].first['@id']
    if uri.nil?
      uri = expanded_metadata[MetadataHelper::SOURCE.to_s].first['@value']
    end

    file_path = URI(uri).path
    file_name = File.basename(file_path)
    doc_type = expanded_metadata[MetadataHelper::TYPE.to_s]
    doc_type = doc_type.first['@value'] unless doc_type.nil?
    msg = nil

    # TODO: replaced by Collections.find_associated_document_by_file_name
    document = item.documents.find_or_initialize_by_file_name(file_name)
    if document.new_record?
      begin
        document.file_path = file_path
        document.doc_type = doc_type
        document.mime_type = mime_type_lookup(file_name)
        document.item = item
        document.item_id = item.id
        document.save
        logger.info "create_document: #{doc_type} Document = #{document.id.to_s}" unless Rails.env.test?
      rescue Exception => e
        logger.error("create_document: Error creating document: #{e.message}")
        document.id = nil
        msg = e.message
      end
    else
      raise ResponseError.new(412), "A file named #{file_name} is already in use by another document of item #{item.get_name}"
    end

    return document.id, msg
  end

  # Adds a document to Sesame and updates the corresponding item in Solr
  def self.add_and_index_document(item, document_json_ld)
    add_and_index_document_in_sesame(item.id, document_json_ld)

    # Reindex item in Solr
    delete_item_from_solr(item.id)
    item.indexed_at = nil
    item.save
    update_item_in_solr(item)
  end

  # Updates the item in Solr by re-indexing that item
  def self.update_item_in_solr(item)
    # ToDo: refactor this workaround into a proper test mock/stub
    if Rails.env.test?
      json = {:cmd => "index", :arg => "#{item.id}"}
      Solr_Worker.new.on_message(JSON.generate(json).to_s)
    else
      stomp_client = Stomp::Client.open "#{STOMP_CONFIG['adapter']}://#{STOMP_CONFIG['host']}:#{STOMP_CONFIG['port']}"
      reindex_item_to_solr(item.id, stomp_client)
      stomp_client.close
    end
  end
end


module SpeakersHelper

  # @@CONTEXT_JSON = JSON.parse(%(
  # {
  #   "@context" : {
  #     "dbp": "http://dbpedia.org/ontology/",
  #     "dcterms": "http://purl.org/dc/terms/",
  #     "foaf": "http://xmlns.com/foaf/0.1/",
  #     "geo": "http://www.w3.org/2003/01/geo/wgs84_pos#",
  #     "iso639": "http://downlode.org/rdf/iso-639/languages#",
  #     "olac": "http://www.language-archives.org/OLAC/1.1/",
  #     "rdf": "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
  #     "rdfs": "http://www.w3.org/2000/01/rdf-schema#",
  #     "xsd": "http://www.w3.org/2001/XMLSchema#"
  #   }
  # }))['@context']

  public

  # Return input identifier by collection name through sesame server
  #
  # @param [String] collection_name collection name
  # @return [String array of URI]
  # @raise Exception if no repository found
  def self.find_speaker_by_collection(collection_name)
    logger.debug "find_speaker_by_collection start: collection_name=#{collection_name}"
    rlt = []

    # if collection_name != 'no_speaker'
    #   rlt = [
    #     "http://app.alveo.edu.au/speakers/#{collection_name}/1_116",
    #     "http://app.alveo.edu.au/speakers/#{collection_name}/1_117"
    #   ]
    # end

    repo = SpeakersHelper.repo(SESAME_CONFIG["url"].to_s, collection_name)

    raise Exception.new("Repository [#{collection_name}] not found in sesame server[#{SESAME_CONFIG['url'].to_s}]") if (repo.nil?)

    sparql = %(
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>
      PREFIX dcterms: <http://purl.org/dc/terms/>

      SELECT ?identifier
      WHERE
      {
        ?input a foaf:Person.
        ?input dcterms:identifier ?identifier.
      }
    )

    solutions = repo.sparql_query(sparql)
    solutions.each do |speaker|
      value = speaker.to_h[:identifier].to_s
      rlt << value
    end

    logger.debug "find_speaker_by_collection end: [#{rlt.count}] input(s) found"

    return rlt
  end

  # Add a new speaker from a JSON-LD payload
  #
  # @param [String] collection_name collection name
  # @param [Hash] json json-ld
  # @return [String] speaker id
  # @raise Exception
  def self.create_speaker(collection_name, json)
    logger.debug "create_speaker start: collection_name[#{collection_name}], json[#{json}] "

    rlt = nil

    repo = SpeakersHelper.repo(SESAME_CONFIG["url"].to_s, collection_name)

    speaker_metadata = JSON::LD::API.compact(json, JsonLdHelper::default_context).except("@context")

    logger.debug "create_speaker: speaker_metadata[#{speaker_metadata}]"

    speaker_id = speaker_metadata["dcterms:identifier"] unless speaker_metadata["dcterms:identifier"].nil?

    # check speaker_id
    raise Exception.new("speaker identifier (dcterms:identifier) not found from request") if (speaker_id.nil?)

    # compose rdf
    rdf = JsonLdHelper::default_rdf_prefix + "\n"

    # compose graph
    speaker_url = "#{SESAME_CONFIG["speaker_url"]}/#{collection_name}/#{speaker_id}"

    rdf += "<#{speaker_url}> a foaf:Person;\n"

    # compose metadata
    speaker_metadata.each_with_index do |(key, value), index|

      if !key.start_with?("@")
        if index == speaker_metadata.size - 1
          rdf += %(#{key} "#{value}" .)
        else
          rdf += %(#{key} "#{value}" ;\n)
        end
      end

    end

    logger.debug "create_speaker: rdf[#{rdf}]"
    repo.send_statements(nil, rdf)

    rlt = speaker_id

    logger.debug "create_speaker end: rlt[#{rlt}]"

    return rlt
  end

  # Return input JSON-LD description
  #
  # @param [String] collection_name collection name
  # @param [String] speaker_id input identifier
  # @raise [Exception] collection error or collection not found
  # @return [JSON]
  def self.find_speaker(collection_name, speaker_id)
    logger.debug "find_speaker start: collection_name[#{collection_name}], speaker_id[#{speaker_id}]"

    rlt = nil

    query = %(
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>
      PREFIX dcterms: <http://purl.org/dc/terms/>

      SELECT ?property ?value
      WHERE {
        ?speaker a foaf:Person.
        ?speaker dcterms:identifier "#{speaker_id}".
        ?speaker ?property ?value
      }
    )

    repo = SpeakersHelper.repo(SESAME_CONFIG["url"].to_s, collection_name)
    solutions = repo.sparql_query(query)

    if solutions.size != 0
      identifier = "#{SESAME_CONFIG["url"]}/#{collection_name}/#{speaker_id}"

      input = JSON.parse %(
      {
        "@id": "#{identifier}",
        "@type": "foaf:Person"
      })

      solutions.each do |solution|
        property = solution.to_h[:property].to_s
        # bypass #type, because fixed type as foaf:Person
        next if property.ends_with?("#type")

        value = solution.to_h[:value].to_s

        input[property] = value
      end

      rlt = JSON::LD::API.compact(input, JsonLdHelper::default_context)
    end


    logger.debug "find_speaker end: rlt[#{rlt}]"

    return rlt

  end

  # Update speaker's metadata
  #
  # PREFIX dcterms: <http://purl.org/dc/terms/>
  # PREFIX foaf: <http://xmlns.com/foaf/0.1/>
  #
  # DELETE {
  #   ?speaker foaf:name ?value .
  #   ?speaker foaf:age ?value .
  # }
  # INSERT {
  #   ?speaker foaf:name "Rodney_1" .
  #   ?speaker foaf:age "12" .
  # }
  # WHERE {
  #   ?speaker ?property ?value .
  #   ?speaker a foaf:Person .
  #   ?speaker dcterms:identifier "1" .
  # }
  #
  # According to https://www.w3.org/TR/sparql11-update/#deleteInsert, DELETE then INSERT
  #
  # @param [String] collection_name
  # @param [String] speaker_id
  # @param [Hash] json
  # @raise
  def self.update_speaker(collection_name, speaker_id, json)
    logger.debug "update_speaker start: collection_name[#{collection_name}], speaker_id[#{speaker_id}], json[#{json}]"

    # check speaker_id
    raise Exception.new("speaker identifier (dcterms:identifier) not found from request") if (speaker_id.nil?)

    repo = SpeakersHelper.repo(SESAME_CONFIG["url"].to_s, collection_name)

    query = ""

    # compose PREFIX part
    JsonLdHelper::default_context.each do |k, v|
      query += "PREFIX #{k.strip.gsub('"', '')}: <#{v['@id']}>\n"
    end

    # empty line between PREFIX and body
    query += "\n"

    # retrieve speaker metadata from json
    speaker_metadata = JSON::LD::API.compact(json, JsonLdHelper::default_context).except("@context")

    # compose DELETE and INSERT part
    query_delete = "DELETE {\n"
    query_insert = "INSERT {\n"

    speaker_metadata.each do |k, v|
      if k != "dcterms:identifier"
        # don't update identifier in case inconsistent
        query_delete += %(  ?speaker #{k} ?value .\n)
        query_insert += %(  ?speaker #{k} "#{v}" .\n)
      end
    end

    query_delete += "}\n"
    query_insert += "}\n"

    query += query_delete + query_insert

    # compose WHERE part
    query += %(
WHERE {
  ?speaker ?property ?value .
  ?speaker a foaf:Person .
  ?speaker dcterms:identifier "#{speaker_id}"
}    )

    logger.debug "update_speaker: query[#{query}]"

    repo.sparql_query(query)

    logger.debug "update_speaker end:"

  end

  # delete input by collection and input id
  #
  # @param [String] collection_name collection name
  # @param [String] speaker_id input identifier
  # @raise [Exception] collection error or collection not found
  def self.delete_speaker(collection_name, speaker_id)
    logger.debug "delete_speaker start: collection_name[#{collection_name}], speaker_id[#{speaker_id}]"

    query = %(
      PREFIX dcterms: <http://purl.org/dc/terms/>
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>

      DELETE {?speaker ?property ?value}
      WHERE {
        ?speaker ?property ?value.
        ?speaker a foaf:Person .
        ?speaker dcterms:identifier "#{speaker_id}"
      }
    )

    repo = SpeakersHelper.repo(SESAME_CONFIG["url"].to_s, collection_name)
    repo.sparql_query(query)

    logger.debug "delete_speaker end:"

  end

  # Retrieve collection repository
  #
  # @param [String] url
  # @param [String] collection_name
  # @raise [Exception] if no related repo found
  # @return [HcsvlabRespository]
  def self.repo(url, collection_name)
    repo = nil

    server = RDF::Sesame::HcsvlabServer.new(url)
    repo = server.repositories[collection_name]

    raise Exception.new("Repository [#{collection_name}] not found in sesame server[#{SESAME_CONFIG['url'].to_s}]") if (repo.nil?)

    repo
  end
end

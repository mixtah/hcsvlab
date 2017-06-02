require 'rdf/json'
require 'rdf/turtle'
require 'json'
require 'json/ld'
require 'json-ld/json_ld_helper'

# DC and DCTERMS Namespaces
# http://wiki.dublincore.org/index.php/FAQ/DC_and_DCTERMS_Namespaces
#
# It is not incorrect to continue using dc:subject and dc:title -- alot of Semantic Web data still does -- and since the range of those properties is unspecified, it is not actually incorrect to use (for example) dc:subject with a literal value or dc:title with a non-literal value. However, good Semantic Web practice is to use properties consistently in accordance with formal ranges, so implementers are encouraged to use the more precisely defined dcterms: properties.

# According to DCMI Metadata Terms (http://dublincore.org/documents/2008/01/14/dcmi-terms/), below 15 properties are in the legacy /elements/1.1 namespace:
# contributor, coverage, creator, date, description, format, identifier, language, publisher, relation, rights, source, subject, title, type

module MetadataHelper

  mattr_reader :lookup, :prefixes

  private
  AUSNC_ROOT_URI = 'http://ns.ausnc.org.au/schemas/'
  ACE_BASE_URI = AUSNC_ROOT_URI + 'ace/' unless const_defined?(:ACE_BASE_URI)
  AUSNC_BASE_URI = AUSNC_ROOT_URI + 'ausnc_md_model/' unless const_defined?(:AUSNC_BASE_URI)
  AUSTLIT_BASE_URI = AUSNC_ROOT_URI + 'austlit/'
  COOEE_BASE_URI = AUSNC_ROOT_URI + 'cooee/'
  GCSAUSE_BASE_URI = AUSNC_ROOT_URI + 'gcsause/'
  ICE_BASE_URI = AUSNC_ROOT_URI + 'ice/'

  PURL_ROOT_URI = 'http://purl.org/'
  DC_TERMS_BASE_URI = PURL_ROOT_URI + 'dc/terms/' unless const_defined?(:DC_TERMS_BASE_URI)
  DC_ELEMENTS_BASE_URI = PURL_ROOT_URI + 'dc/elements/1.1/' unless const_defined?(:DC_ELEMENTS_BASE_URI)
  PURL_BIBO_BASE_URI = PURL_ROOT_URI + 'ontology/bibo/'
  PURL_VOCAB_BASE_URI = PURL_ROOT_URI + 'vocab/bio/0.1/'

  OLAC_BASE_URI = 'http://www.language-archives.org/OLAC/1.1/'
  FOAF_BASE_URI = 'http://xmlns.com/foaf/0.1/'
  RDF_BASE_URI = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#'
  LOC_BASE_URI = 'http://www.loc.gov/loc.terms/relators/'
  ALVEO_BASE_URI = 'http://alveo.edu.au/vocabulary/'

  AUSTALK_BASE_URI = 'http://ns.austalk.edu.au/'

  @@lookup = {}
  @@prefixes = {
    ACE_BASE_URI => "ACE",
    AUSNC_BASE_URI => "AUSNC",
    AUSTLIT_BASE_URI => "AUSTLIT",
    COOEE_BASE_URI => "COOEE",
    GCSAUSE_BASE_URI => "GCSAUSE",
    ICE_BASE_URI => "ICE",

    DC_TERMS_BASE_URI => "DC",
    DC_ELEMENTS_BASE_URI => "DC",
    PURL_BIBO_BASE_URI => "PURL_BIBO",
    PURL_VOCAB_BASE_URI => "PURL_VOCAB",

    FOAF_BASE_URI => "FOAF",
    OLAC_BASE_URI => "OLAC",
    RDF_BASE_URI => "RDF",
    LOC_BASE_URI => "LoC",

    AUSTALK_BASE_URI => "AUSTALK",

    ALVEO_BASE_URI => "Alveo"
  }

  public
  #
  # AUSNC
  #
  AUDIENCE = RDF::URI(AUSNC_BASE_URI + 'audience') unless const_defined?(:AUDIENCE)
  COMMUNICATION_CONTEXT = RDF::URI(AUSNC_BASE_URI + 'communication_context') unless const_defined?(:COMMUNICATION_CONTEXT)
  DOCUMENT = RDF::URI(AUSNC_BASE_URI + 'document') unless const_defined?(:DOCUMENT)
  INTERACTIVITY = RDF::URI(AUSNC_BASE_URI + 'interactivity') unless const_defined?(:INTERACTIVITY)
  LOCALITY_NAME = RDF::URI(AUSNC_BASE_URI + 'locality_name')
  MODE = RDF::URI(AUSNC_BASE_URI + 'mode') unless const_defined?(:MODE)
  SPEECH_STYLE = RDF::URI(AUSNC_BASE_URI + 'speech_style') unless const_defined?(:SPEECH_STYLE)

  @@lookup[AUDIENCE.to_s] = prefixes[AUSNC_BASE_URI] + "_audience_facet"
  @@lookup[COMMUNICATION_CONTEXT.to_s] = prefixes[AUSNC_BASE_URI] + "_communication_context_facet"
  @@lookup[DOCUMENT.to_s] = prefixes[AUSNC_BASE_URI] + "_document"
  @@lookup[INTERACTIVITY.to_s] = prefixes[AUSNC_BASE_URI] + "_interactivity_facet"
  @@lookup[LOCALITY_NAME.to_s] = prefixes[AUSNC_BASE_URI] + "_locality_name"
  @@lookup[MODE.to_s] = prefixes[AUSNC_BASE_URI] + "_mode_facet"
  @@lookup[SPEECH_STYLE.to_s] = prefixes[AUSNC_BASE_URI] + "_speech_style_facet"

  #
  # AUSTLIT
  #
  LOCATION = RDF::URI(AUSTLIT_BASE_URI + 'location') unless const_defined?(:LOCATION)

  @@lookup[LOCATION.to_s] = prefixes[AUSTLIT_BASE_URI] + "_location"

  #
  # DCTERMS
  #
  IS_PART_OF = RDF::URI(DC_TERMS_BASE_URI + 'isPartOf') unless const_defined?(:IS_PART_OF)
  TYPE = RDF::URI(DC_TERMS_BASE_URI + 'type') unless const_defined?(:TYPE)
  EXTENT = RDF::URI(DC_TERMS_BASE_URI + 'extent') unless const_defined?(:EXTENT)
  CREATED = RDF::URI(DC_TERMS_BASE_URI + 'created') unless const_defined?(:CREATED)
  IDENTIFIER = RDF::URI(DC_TERMS_BASE_URI + 'identifier') unless const_defined?(:IDENTIFIER)
  SOURCE = RDF::URI(DC_TERMS_BASE_URI + 'source') unless const_defined?(:SOURCE)
  RIGHTS = RDF::URI(DC_TERMS_BASE_URI + 'rights') unless const_defined?(:RIGHTS)
  DESCRIPTION = RDF::URI(DC_TERMS_BASE_URI + 'description') unless const_defined?(:DESCRIPTION)
  BIBLIOGRAPHIC_CITATION = RDF::URI(DC_TERMS_BASE_URI + 'bibliographicCitation') unless const_defined?(:BIBLIO_CITATION)
  ABSTRACT = RDF::URI(DC_TERMS_BASE_URI + 'abstract') unless const_defined?(:ABSTRACT)
  # KL - collection enhancement
  LANGUAGE = RDF::URI(DC_TERMS_BASE_URI + 'language') unless const_defined?(:LANGUAGE)
  LICENCE = RDF::URI(DC_TERMS_BASE_URI + 'license') unless const_defined?(:LICENCE)

  #
  # DC
  #
  DC_CREATOR = RDF::URI(DC_ELEMENTS_BASE_URI + 'creator') unless const_defined?(:DC_CREATOR)
  DC_TITLE = RDF::URI(DC_ELEMENTS_BASE_URI + 'title') unless const_defined?(:DC_TITLE)

  # KL: compact prefix
  PFX_TITLE = "dc:title"
  PFX_OWNER = "marcrel:OWN"
  PFX_LANGUAGE = "dcterms:language"
  PFX_CREATION_DATE = "dcterms:created"
  PFX_CREATOR = "dc:creator"
  PFX_LICENCE = "dcterms:license"
  PFX_ABSTRACT = "dcterms:abstract"

  @@lookup[IS_PART_OF.to_s] = prefixes[DC_TERMS_BASE_URI] + "_is_part_of"
  @@lookup[EXTENT.to_s] = prefixes[DC_TERMS_BASE_URI] + "_extent"
  @@lookup[CREATED.to_s] = prefixes[DC_TERMS_BASE_URI] + "_created"
  @@lookup[IDENTIFIER.to_s] = prefixes[DC_TERMS_BASE_URI] + "_identifier"
  @@lookup[SOURCE.to_s] = prefixes[DC_TERMS_BASE_URI] + "_source"
  @@lookup[DC_TITLE.to_s] = prefixes[DC_TERMS_BASE_URI] + "_title"
  @@lookup[TYPE.to_s] = prefixes[DC_TERMS_BASE_URI] + "_type_facet"
  @@lookup[RIGHTS.to_s] = prefixes[DC_TERMS_BASE_URI] + "_rights"
  @@lookup[DESCRIPTION.to_s] = prefixes[DC_TERMS_BASE_URI] + "_description"
  @@lookup[BIBLIOGRAPHIC_CITATION.to_s] = prefixes[DC_TERMS_BASE_URI] + "_bibliographicCitation"
  @@lookup[ABSTRACT.to_s] = prefixes[DC_TERMS_BASE_URI] + "_abstract"
  # KL - collection enhancement
  @@lookup[LANGUAGE.to_s] = prefixes[DC_TERMS_BASE_URI] + "_language"
  @@lookup[DC_CREATOR.to_s] = prefixes[DC_TERMS_BASE_URI] + "_creator"
  @@lookup[LICENCE.to_s] = prefixes[DC_TERMS_BASE_URI] + "_licence"


  #
  # OLAC
  #
  DISCOURSE_TYPE = RDF::URI(OLAC_BASE_URI + 'discourse_type') unless const_defined?(:DISCOURSE_TYPE)
  LANGUAGE = RDF::URI(OLAC_BASE_URI + 'language') unless const_defined?(:LANGUAGE)
  OLAC_SUBJECT = RDF::URI(OLAC_BASE_URI + 'subject') unless const_defined?(:OLAC_SUBJECT)

  @@lookup[DISCOURSE_TYPE.to_s] = prefixes[OLAC_BASE_URI] + "_discourse_type_facet"
  @@lookup[LANGUAGE.to_s] = prefixes[OLAC_BASE_URI] + "_language_facet"
  @@lookup[OLAC_SUBJECT.to_s] = prefixes[OLAC_BASE_URI] + "_subject_facet"
  # code => name
  PFX_OLAC_SUBJECT = "olac:subject"

  OLAC_LINGUISTIC_SUBJECT_HASH = {
    "Anthropological Linguistics" => "Anthropological Linguistics",
    "Applied Linguistics" => "Applied Linguistics",
    "Cognitive Science" => "Cognitive Science",
    "Computational Linguistics" => "Computational Linguistics",
    "Discourse Analysis" => "Discourse Analysis",
    "Forensic Linguistics" => "Forensic Linguistics",
    "General Linguistics" => "General Linguistics",
    "Historical Linguistics" => "Historical Linguistics",
    "History of Linguistics" => "History of Linguistics",
    "Language Acquisition" => "Language Acquisition",
    "Language Documentation" => "Language Documentation",
    "Lexicography" => "Lexicography",
    "Linguistics and Literature" => "Linguistics and Literature",
    "Linguistic Theories" => "Linguistic Theories",
    "Mathematical Linguistics" => "Mathematical Linguistics",
    "Morphology" => "Morphology",
    "Neurolinguistics" => "Neurolinguistics",
    "Philosophy of Language" => "Philosophy of Language",
    "Phonetics" => "Phonetics",
    "Phonology" => "Phonology",
    "Pragmatics" => "Pragmatics",
    "Psycholinguistics" => "Psycholinguistics",
    "Semantics" => "Semantics",
    "Sociolinguistics" => "Sociolinguistics",
    "Syntax" => "Syntax",
    "Text and Corpus Linguistics" => "Text and Corpus Linguistics",
    "Translating and Interpreting" => "Translating and Interpreting",
    "Typology" => "Typology",
    "Writing Systems" => "Writing Systems"
  }

  #
  # RDF
  #
  RDF_TYPE = RDF::URI(RDF_BASE_URI + 'type') unless const_defined?(:RDF_TYPE)

  @@lookup[RDF_TYPE.to_s] = prefixes[RDF_BASE_URI] + "_type"


  #
  # LoC
  #
  LOC_RESPONSIBLE_PERSON = RDF::URI(LOC_BASE_URI + 'rpy') unless const_defined?(:LOC_RESPONSIBLE_PERSON)
  LOC_OWNER = RDF::URI(LOC_BASE_URI + 'OWN') unless const_defined?(:LOC_OWNER)

  @@lookup[LOC_RESPONSIBLE_PERSON.to_s] = prefixes[LOC_BASE_URI] + "_responsible_person"
  @@lookup[LOC_OWNER.to_s] = prefixes[LOC_BASE_URI] + "_OWN"

  #
  # AUSTALK
  #
  AUSTALK_COMPONENT = RDF::URI(AUSTALK_BASE_URI + 'component') unless const_defined?(:AUSTALK_COMPONENT)
  AUSTALK_COMPONENTNAME = RDF::URI(AUSTALK_BASE_URI + 'componentName') unless const_defined?(:AUSTALK_COMPONENTNAME)
  AUSTALK_PROMPT = RDF::URI(AUSTALK_BASE_URI + 'prompt') unless const_defined?(:AUSTALK_PROMPT)
  AUSTALK_PROTOTYPE = RDF::URI(AUSTALK_BASE_URI + 'prototype') unless const_defined?(:AUSTALK_PROTOTYPE)
  AUSTALK_SESSION = RDF::URI(AUSTALK_BASE_URI + 'session') unless const_defined?(:AUSTALK_SESSION)
  AUSTALK_TIMESTAMP = RDF::URI(AUSTALK_BASE_URI + 'timestamp') unless const_defined?(:AUSTALK_TIMESTAMP)
  AUSTALK_VERSION = RDF::URI(AUSTALK_BASE_URI + 'version') unless const_defined?(:AUSTALK_VERSION)

  #
  # HCSVLAB
  #
  COLLECTION = RDF::URI('collection_name_facet') unless const_defined?(:COLLECTION)
  IDENT = RDF::URI(ALVEO_BASE_URI + 'ident') unless const_defined?(:IDENT)
  HAS_LICENCE= RDF::URI('has_licence') unless const_defined?(:HAS_LICENCE)
  INDEXABLE_DOCUMENT= RDF::URI(ALVEO_BASE_URI + 'indexable_document') unless const_defined?(:INDEXABLE_DOCUMENT)
  DISPLAY_DOCUMENT = RDF::URI(ALVEO_BASE_URI + 'display_document') unless const_defined?(:DISPLAY_DOCUMENT)

  #
  # FOAF
  #
  FOAF_DOCUMENT = RDF::URI(FOAF_BASE_URI + 'Document') unless const_defined?(:FOAF_DOCUMENT)

  @@lookup[FOAF_DOCUMENT.to_s] = prefixes[FOAF_BASE_URI] + "_Document"

  #
  # Language
  #
  # LANGUAGE_HASH = {
  #     'Chinese, Mandarin' => 'Chinese, Mandarin',
  #     'English' => 'English',
  #     'German, Standard' => 'German, Standard'
  # }

  #
  # Licence
  #


  #
  # short_form - return a shortened form of the given uri (which will
  #              be .to_s'ed first)
  #
  def self::short_form(uri)
    uri = uri.to_s
    return @@lookup[uri] if @@lookup.has_key?(uri)
    @@prefixes.keys.each {|p|
      if uri.start_with?(p)
        uri = uri.sub(p, "#{@@prefixes[p]}_")
        return tidy(uri)
      end
    }
    return tidy(uri)
  end

  #
  # tidy - return a version of the given string with "special"
  #        characters replaced by "safe" ones
  #
  def self::tidy(uri)
    return uri.to_s.gsub(/\W/, '_').gsub(/_{2,}/, '_')
  end

  def self::corpus_dir_by_name(collection_name)
    File.join(Rails.application.config.api_collections_location, collection_name)
  end

  #
  # @param collection_name
  # @param collection_manifest
  def self::create_manifest(
    collection_name,
      collection_manifest={"collection_name" => collection_name, "files" => {}})

    corpus_dir = corpus_dir_by_name(collection_name)
    FileUtils.mkdir_p(corpus_dir)

    manifest_file_path = File.join(corpus_dir, MANIFEST_FILE_NAME)
    File.open(manifest_file_path, 'w') do |file|
      file.puts(collection_manifest.to_json)
    end
  end

  # store json data into db
  def self::update_collection_metadata_from_json(collection_name, json_metadata)
    update_rdf_graph(collection_name, json_to_rdf_graph(json_metadata))
  end

  # Save or update collection record with metadata (rdf graph) into DB
  def self::update_rdf_graph(collection_name, graph=nil)
    logger.debug "update_rdf_graph: start - collection_name[#{collection_name}], graph[#{graph}]"

    collection = Collection.find_by_name(collection_name)

    if collection.nil?
      #   new collection
      collection = Collection.new
      collection.name = collection_name
      unless graph.nil?
        collection.uri = graph.statements.first.subject.to_s
      else
        collection.uri = collection_url(collection_name)
      end

      collection.save!

      # reload collection
      collection = Collection.find_by_name(collection_name)

      logger.debug "update_rdf_graph: new collection created: #{collection.name}"
    end

    unless graph.nil?
      # remove all CollectionProperty with collection_id
      CollectionProperty.delete_all "collection_id = #{collection.id}"

      json = rdf_graph_to_json(graph)

      logger.debug "update_rdf_graph: json=#{json}"

      json.each do |property, value|
        # logger.debug "update_rdf_graph: [#{property}] => (#{value.class}):#{value}"
        collection_property = CollectionProperty.new

        collection_property.collection_id = collection.id
        collection_property.property = property
        if property == "@id"
          #   @id must equal to collection.uri
          collection_property.value = collection.uri
        else
          collection_property.value = value.to_s.gsub(/=>/, ':')
        end

        # logger.debug "update_rdf_graph: add #{collection_property.property}=#{collection_property.value}"

        collection_property.save
      end
    end

    logger.debug "update_rdf_graph: end"

    collection

  end

  def self::valid_json?(json)
    begin
      JSON.parse(json)
      return true
    rescue JSON::ParserError => e
      return false
    end
  end


  # Use json-ld to convert RDF graph to JSON
  def self::rdf_graph_to_json(graph)
    logger.debug "rdf_graph_to_json: graph=#{graph.inspect}"
    compacted_json = nil

    context = {"@context" => JsonLdHelper::default_context}

    JSON::LD::API::fromRDF(graph) do |expanded|
      compacted_json = JSON::LD::API.compact(expanded, context['@context'])
    end

    logger.debug "rdf_graph_to_json: json=#{compacted_json.to_s}"

    compacted_json
  end

  # Use json-ld to convert JSON to RDF graph
  def self::json_to_rdf_graph(json, format=:ttl)
    logger.debug "json_to_rdf_graph start: json=#{json.to_s}"
    graph = RDF::Graph.new << JSON::LD::API.toRDF(json)

    logger.debug "json_to_rdf_graph end: graph=#{graph.dump(format)}"
    # graph.dump(format)

    graph
  end

  # Load collection metadata from DB then convert to RDF graph
  #
  # @param collection_name
  def self::load_rdf_graph(collection_name)
    json_to_rdf_graph(load_json(collection_name))
  end

  def self::load_json(collection_name)
    collection = Collection.find_by_name(collection_name)

    if collection.nil?
      logger.error "Could not find collection [#{collection_name}]"
      raise "Could not find collection [#{collection_name}]"
    end

    coll_properties = CollectionProperty.where(:collection_id => collection.id)

    hash = {}
    coll_properties.each do |cp|
      # puts "loaded_property=#{cp.property}, loaded_value=#{cp.value}"
      if valid_json?(cp.value)
        hash[cp.property] = JSON.parse(cp.value)
      else
        hash[cp.property] = cp.value
      end
    end

    JSON.parse(hash.to_json)
  end

  def self::load_metadata_from_collection(collection_name)
    collection = Collection.find_by_name(collection_name)

    properties = {}
    collection.collection_properties.each do |prop|
      # remove the leading or trailing quote
      # properties[prop.property.gsub!(/^\"|\"?$/, '')] = prop.value
      properties[prop.property] = prop.value
    end

    properties
  end

  # Complete collection metadata with default metadata value rules.
  # Handle both nil and blank case.
  # Default metadata value:
  #   dcterms:title (Title, default=name)
  #   dcterms:language (Language, default='English')
  #   dcterms:created (Creation Date, default=current date)
  #   dcterms:creator (Creator, default=logged in user)
  #   dcterms:licence (Licence, default='Creative Commons v3.0 BY')
  #
  def self::not_empty_collection_metadata!(collection_name, full_name, metadata)
    logger.debug "not_empty_collection_metadata!: begin #{collection_name}, #{full_name}, #{metadata}"

    metadata_fields = {
      MetadataHelper::DC_TITLE.to_s => collection_name,
      MetadataHelper::LANGUAGE.to_s => 'eng - English',
      MetadataHelper::CREATED.to_s => DateTime.now.strftime("%d/%m/%Y"),
      MetadataHelper::DC_CREATOR.to_s => full_name,
      MetadataHelper::LICENCE.to_s => 'Creative Commons v3.0 BY'
    }

    metadata_fields.each do |field, value|
      metadata[field] = value if metadata[field].nil? || metadata[field].empty?
    end

    logger.debug "not_empty_collection_metadata!: end #{metadata}"

    metadata
  end

  #
  # Load metadata searchable fields
  #
  def self::searchable_fields
    ItemMetadataFieldNameMapping.order('lower(user_friendly_name)').select([:rdf_name, :user_friendly_name])
  end
end

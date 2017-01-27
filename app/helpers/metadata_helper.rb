require 'rdf/json'
require 'rdf/turtle'
require 'json'
require 'json/ld'

module MetadataHelper

  mattr_reader :lookup, :prefixes

private
  AUSNC_ROOT_URI = 'http://ns.ausnc.org.au/schemas/'
    ACE_BASE_URI     = AUSNC_ROOT_URI + 'ace/' unless const_defined?(:ACE_BASE_URI)
    AUSNC_BASE_URI   = AUSNC_ROOT_URI + 'ausnc_md_model/' unless const_defined?(:AUSNC_BASE_URI)
    AUSTLIT_BASE_URI = AUSNC_ROOT_URI + 'austlit/'
    COOEE_BASE_URI   = AUSNC_ROOT_URI + 'cooee/'
    GCSAUSE_BASE_URI = AUSNC_ROOT_URI + 'gcsause/'
    ICE_BASE_URI     = AUSNC_ROOT_URI + 'ice/'

  PURL_ROOT_URI = 'http://purl.org/'
    DC_TERMS_BASE_URI    = PURL_ROOT_URI + 'dc/terms/' unless const_defined?(:DC_TERMS_BASE_URI)
    DC_ELEMENTS_BASE_URI = PURL_ROOT_URI + 'dc/elements/1.1/' unless const_defined?(:DC_ELEMENTS_BASE_URI)
    PURL_BIBO_BASE_URI   = PURL_ROOT_URI + 'ontology/bibo/'
    PURL_VOCAB_BASE_URI  = PURL_ROOT_URI + 'vocab/bio/0.1/'

  OLAC_BASE_URI    = 'http://www.language-archives.org/OLAC/1.1/'
  FOAF_BASE_URI    = 'http://xmlns.com/foaf/0.1/'
  RDF_BASE_URI     = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#'
  LOC_BASE_URI     = 'http://www.loc.gov/loc.terms/relators/'
  ALVEO_BASE_URI   = 'http://alveo.edu.au/vocabulary/'

  AUSTALK_BASE_URI = 'http://ns.austalk.edu.au/'

  @@lookup = {}
  @@prefixes = {
    ACE_BASE_URI         => "ACE",
    AUSNC_BASE_URI       => "AUSNC",
    AUSTLIT_BASE_URI     => "AUSTLIT",
    COOEE_BASE_URI       => "COOEE",
    GCSAUSE_BASE_URI     => "GCSAUSE",
    ICE_BASE_URI         => "ICE",

    DC_TERMS_BASE_URI    => "DC",
    DC_ELEMENTS_BASE_URI => "DC",
    PURL_BIBO_BASE_URI   => "PURL_BIBO",
    PURL_VOCAB_BASE_URI  => "PURL_VOCAB",

    FOAF_BASE_URI        => "FOAF",
    OLAC_BASE_URI        => "OLAC",
    RDF_BASE_URI         => "RDF",
    LOC_BASE_URI         => "LoC",

    AUSTALK_BASE_URI     => "AUSTALK",

    ALVEO_BASE_URI       => "Alveo"
  }

public
  #
  # AUSNC
  #
  AUDIENCE              = RDF::URI(AUSNC_BASE_URI + 'audience') unless const_defined?(:AUDIENCE)
  COMMUNICATION_CONTEXT = RDF::URI(AUSNC_BASE_URI + 'communication_context') unless const_defined?(:COMMUNICATION_CONTEXT)
  DOCUMENT              = RDF::URI(AUSNC_BASE_URI + 'document') unless const_defined?(:DOCUMENT)
  INTERACTIVITY         = RDF::URI(AUSNC_BASE_URI + 'interactivity') unless const_defined?(:INTERACTIVITY)
  LOCALITY_NAME         = RDF::URI(AUSNC_BASE_URI + 'locality_name')
  MODE                  = RDF::URI(AUSNC_BASE_URI + 'mode') unless const_defined?(:MODE)
  SPEECH_STYLE          = RDF::URI(AUSNC_BASE_URI + 'speech_style') unless const_defined?(:SPEECH_STYLE)

  @@lookup[AUDIENCE.to_s]              = prefixes[AUSNC_BASE_URI] + "_audience_facet"
  @@lookup[COMMUNICATION_CONTEXT.to_s] = prefixes[AUSNC_BASE_URI] + "_communication_context_facet"
  @@lookup[DOCUMENT.to_s]              = prefixes[AUSNC_BASE_URI] + "_document"
  @@lookup[INTERACTIVITY.to_s]         = prefixes[AUSNC_BASE_URI] + "_interactivity_facet"
  @@lookup[LOCALITY_NAME.to_s]         = prefixes[AUSNC_BASE_URI] + "_locality_name"
  @@lookup[MODE.to_s]                  = prefixes[AUSNC_BASE_URI] + "_mode_facet"
  @@lookup[SPEECH_STYLE.to_s]          = prefixes[AUSNC_BASE_URI] + "_speech_style_facet"

  #
  # AUSTLIT
  #
  LOCATION = RDF::URI(AUSTLIT_BASE_URI + 'location') unless const_defined?(:LOCATION)

  @@lookup[LOCATION.to_s] = prefixes[AUSTLIT_BASE_URI] + "_location"

  #
  # DC
  #
  IS_PART_OF             = RDF::URI(DC_TERMS_BASE_URI + 'isPartOf') unless const_defined?(:IS_PART_OF)
  TYPE                   = RDF::URI(DC_TERMS_BASE_URI + 'type') unless const_defined?(:TYPE)
  EXTENT                 = RDF::URI(DC_TERMS_BASE_URI + 'extent') unless const_defined?(:EXTENT)
  CREATED                = RDF::URI(DC_TERMS_BASE_URI + 'created') unless const_defined?(:CREATED)
  IDENTIFIER             = RDF::URI(DC_TERMS_BASE_URI + 'identifier') unless const_defined?(:IDENTIFIER)
  SOURCE                 = RDF::URI(DC_TERMS_BASE_URI + 'source') unless const_defined?(:SOURCE)
  TITLE                  = RDF::URI(DC_TERMS_BASE_URI + 'title') unless const_defined?(:TITLE)
  RIGHTS                 = RDF::URI(DC_TERMS_BASE_URI + 'rights') unless const_defined?(:RIGHTS)
  DESCRIPTION            = RDF::URI(DC_TERMS_BASE_URI + 'description') unless const_defined?(:DESCRIPTION)
  BIBLIOGRAPHIC_CITATION = RDF::URI(DC_TERMS_BASE_URI + 'bibliographicCitation') unless const_defined?(:BIBLIO_CITATION)
  ABSTRACT               = RDF::URI(DC_TERMS_BASE_URI + 'abstract') unless const_defined?(:ABSTRACT)
  # KL - collection enhancement
  DC_LANGUAGE               = RDF::URI(DC_TERMS_BASE_URI + 'language') unless const_defined?(:DC_LANGUAGE)
  CREATOR                = RDF::URI(DC_TERMS_BASE_URI + 'creator') unless const_defined?(:CREATOR)
  LICENCE                = RDF::URI(DC_TERMS_BASE_URI + 'licence') unless const_defined?(:LICENCE)


  # KL: collection properties prefix
  PFX_TITLE             = "dcterms:title"
  PFX_OWNER             = "ns1:OWN"
  PFX_LANGUAGE          = "dcterms:language"
  PFX_CREATION_DATE     = "dcterms:created"
  PFX_CREATOR           = "dcterms:creator"
  PFX_LICENCE           = "dcterms:licence"
  PFX_ABSTRACT          = "dcterms:abstract"


  @@lookup[IS_PART_OF.to_s]             = prefixes[DC_TERMS_BASE_URI] + "_is_part_of"
  @@lookup[EXTENT.to_s]                 = prefixes[DC_TERMS_BASE_URI] + "_extent"
  @@lookup[CREATED.to_s]                = prefixes[DC_TERMS_BASE_URI] + "_created"
  @@lookup[IDENTIFIER.to_s]             = prefixes[DC_TERMS_BASE_URI] + "_identifier"
  @@lookup[SOURCE.to_s]                 = prefixes[DC_TERMS_BASE_URI] + "_source"
  @@lookup[TITLE.to_s]                  = prefixes[DC_TERMS_BASE_URI] + "_title"
  @@lookup[TYPE.to_s]                   = prefixes[DC_TERMS_BASE_URI] + "_type_facet"
  @@lookup[RIGHTS.to_s]                 = prefixes[DC_TERMS_BASE_URI] + "_rights"
  @@lookup[DESCRIPTION.to_s]            = prefixes[DC_TERMS_BASE_URI] + "_description"
  @@lookup[BIBLIOGRAPHIC_CITATION.to_s] = prefixes[DC_TERMS_BASE_URI] + "_bibliographicCitation"
  @@lookup[ABSTRACT.to_s]               = prefixes[DC_TERMS_BASE_URI] + "_abstract"
  # KL - collection enhancement
  @@lookup[DC_LANGUAGE.to_s]            = prefixes[DC_TERMS_BASE_URI] + "_language"
  @@lookup[CREATOR.to_s]                = prefixes[DC_TERMS_BASE_URI] + "_creator"
  @@lookup[LICENCE.to_s]                = prefixes[DC_TERMS_BASE_URI] + "_licence"


  #
  # OLAC
  #
  DISCOURSE_TYPE = RDF::URI(OLAC_BASE_URI + 'discourse_type') unless const_defined?(:DISCOURSE_TYPE)
  LANGUAGE       = RDF::URI(OLAC_BASE_URI + 'language') unless const_defined?(:LANGUAGE)

  @@lookup[DISCOURSE_TYPE.to_s] = prefixes[OLAC_BASE_URI] + "_discourse_type_facet"
  @@lookup[LANGUAGE.to_s]       = prefixes[OLAC_BASE_URI] + "_language_facet"
  # code => name
  PFX_OLAC = "olac11:"
  OLAC_LINGUISTIC_SUBJECT_HASH = {
      "#{PFX_OLAC}anthropological_linguistics" => "Anthropological Linguistics",
      "#{PFX_OLAC}applied_linguistics" => "Applied Linguistics",
      "#{PFX_OLAC}cognitive_science" => "Cognitive Science",
      "#{PFX_OLAC}computational_linguistics" => "Computational Linguistics",
      "#{PFX_OLAC}discourse_analysis" => "Discourse Analysis",
      "#{PFX_OLAC}forensic_linguistics" => "Forensic Linguistics",
      "#{PFX_OLAC}general_linguistics" => "General Linguistics",
      "#{PFX_OLAC}historical_linguistics" => "Historical Linguistics",
      "#{PFX_OLAC}history_of_linguistics" => "History of Linguistics",
      "#{PFX_OLAC}language_acquisition" => "Language Acquisition",
      "#{PFX_OLAC}language_documentation" => "Language Documentation",
      "#{PFX_OLAC}lexicography" => "Lexicography",
      "#{PFX_OLAC}linguistics_and_literature" => "Linguistics and Literature",
      "#{PFX_OLAC}linguistic_theories" => "Linguistic Theories",
      "#{PFX_OLAC}mathematical_linguistics" => "Mathematical Linguistics",
      "#{PFX_OLAC}morphology" => "Morphology",
      "#{PFX_OLAC}neurolinguistics" => "Neurolinguistics",
      "#{PFX_OLAC}philosophy_of_language" => "Philosophy of Language",
      "#{PFX_OLAC}phonetics" => "Phonetics",
      "#{PFX_OLAC}phonology" => "Phonology",
      "#{PFX_OLAC}pragmatics" => "Pragmatics",
      "#{PFX_OLAC}psycholinguistics" => "Psycholinguistics",
      "#{PFX_OLAC}semantics" => "Semantics",
      "#{PFX_OLAC}sociolinguistics" => "Sociolinguistics",
      "#{PFX_OLAC}syntax" => "Syntax",
      "#{PFX_OLAC}text_and_corpus_linguistics" => "Text and Corpus Linguistics",
      "#{PFX_OLAC}translating_and_interpreting" => "Translating and Interpreting",
      "#{PFX_OLAC}typology" => "Typology",
      "#{PFX_OLAC}writing_systems" => "Writing Systems"
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
  LOC_OWNER              = RDF::URI(LOC_BASE_URI + 'OWN') unless const_defined?(:LOC_OWNER)

  @@lookup[LOC_RESPONSIBLE_PERSON.to_s] = prefixes[LOC_BASE_URI] + "_responsible_person"
  @@lookup[LOC_OWNER.to_s]              = prefixes[LOC_BASE_URI] + "_OWN"

  #
  # AUSTALK
  #
  AUSTALK_COMPONENT     = RDF::URI(AUSTALK_BASE_URI + 'component') unless const_defined?(:AUSTALK_COMPONENT)
  AUSTALK_COMPONENTNAME = RDF::URI(AUSTALK_BASE_URI + 'componentName') unless const_defined?(:AUSTALK_COMPONENTNAME)
  AUSTALK_PROMPT        = RDF::URI(AUSTALK_BASE_URI + 'prompt') unless const_defined?(:AUSTALK_PROMPT)
  AUSTALK_PROTOTYPE     = RDF::URI(AUSTALK_BASE_URI + 'prototype') unless const_defined?(:AUSTALK_PROTOTYPE)
  AUSTALK_SESSION       = RDF::URI(AUSTALK_BASE_URI + 'session') unless const_defined?(:AUSTALK_SESSION)
  AUSTALK_TIMESTAMP     = RDF::URI(AUSTALK_BASE_URI + 'timestamp') unless const_defined?(:AUSTALK_TIMESTAMP)
  AUSTALK_VERSION       = RDF::URI(AUSTALK_BASE_URI + 'version') unless const_defined?(:AUSTALK_VERSION)

  #
  # HCSVLAB
  #
  COLLECTION = RDF::URI('collection_name_facet') unless const_defined?(:COLLECTION)
  IDENT      = RDF::URI(ALVEO_BASE_URI + 'ident') unless const_defined?(:IDENT)
  HAS_LICENCE= RDF::URI('has_licence') unless const_defined?(:HAS_LICENCE)
  INDEXABLE_DOCUMENT= RDF::URI(ALVEO_BASE_URI + 'indexable_document') unless const_defined?(:INDEXABLE_DOCUMENT)
  DISPLAY_DOCUMENT  = RDF::URI(ALVEO_BASE_URI + 'display_document') unless const_defined?(:DISPLAY_DOCUMENT)

  #
  # FOAF
  #
  FOAF_DOCUMENT = RDF::URI(FOAF_BASE_URI + 'Document') unless const_defined?(:FOAF_DOCUMENT)

  @@lookup[FOAF_DOCUMENT.to_s] = prefixes[FOAF_BASE_URI] + "_Document"

  #
  # Language
  #
  LANGUAGE_HASH = {
      'Chinese, Mandarin' => 'Chinese, Mandarin',
      'English' => 'English',
      'German, Standard' => 'German, Standard'
  }

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
    @@prefixes.keys.each { |p|
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
  def self::update_rdf_graph(
      collection_name,
      graph=nil)
    collection = Collection.find_by_name(collection_name)

    if collection.nil?
    #   new collection
      collection = Collection.new
      collection.name = collection_name
      collection.save

      logger.debug "new collection created: #{collection}"
    end

    unless graph.nil?
      # remove all CollectionProperty with collection_id
      logger.debug "graph is not nil, collection.id=#{collection.id}"

      CollectionProperty.delete_all "collection_id = #{collection.id}"

      json = rdf_graph_to_json(graph)

      logger.debug "json=#{json}"

      json.each do |property, value|
        logger.debug "[#{property}] => (#{value.class}):#{value}"

        collection_property = CollectionProperty.new

        collection_property.collection_id = collection.id
        collection_property.property = property
        collection_property.value = value.to_s.gsub(/=>/, ':')

        logger.debug "collection_property.property=#{collection_property.property}, collection_property.value=#{collection_property.value}"

        collection_property.save
      end
    end

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
    logger.debug "rdf_graph_to_json: graph=#{graph.to_s}"
    compacted_json = nil

    context = JSON.parse '{
      "@context": {
        "ns1": "http://www.loc.gov/loc.terms/relators/",
        "olac11": "http://www.language-archives.org/OLAC/1.1/",
        "dcterms": "http://purl.org/dc/terms/",
        "rdf": "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
        "rdfs": "http://www.w3.org/2000/01/rdf-schema#",
        "xsd": "http://www.w3.org/2001/XMLSchema#"
        }
    }'

    JSON::LD::API::fromRDF(graph) do |expanded|
      compacted_json = JSON::LD::API.compact(expanded, context['@context'])
    end

    logger.debug "rdf_graph_to_json: json=#{compacted_json.to_s}"

    compacted_json
  end

  # Use json-ld to convert JSON to RDF graph
  def self::json_to_rdf_graph(json, format=:ttl)
    logger.debug "json_to_rdf_graph: json=#{json.to_s}"
    graph = RDF::Graph.new << JSON::LD::API.toRDF(json)
    # graph.dump(format)
    logger.debug "json_to_rdf_graph: graph=#{graph.to_s}"
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

  def self.demo_text
    text = %(
# Intro
Go ahead, play around with the editor! Be sure to check out **bold** and *italic* styling, or even [links](https://google.com). You can type the Markdown syntax, use the toolbar, or use shortcuts like `cmd-b` or `ctrl-b`.

## Lists
Unordered lists can be started using the toolbar or by typing `* `, `- `, or `+ `. Ordered lists can be started by typing `1. `.

#### Unordered
* Lists are a piece of cake
* They even auto continue as you type
* A double enter will end them
* Tabs and shift-tabs work too

#### Ordered
1. Numbered lists...
2. ...work too!

## What about images?
![Yes](https://i.imgur.com/sZlktY7.png)

## What about videos?
<iframe width="560" height="315" src="https://www.youtube.com/embed/0R1Nf4MS9hM" frameborder="0" allowfullscreen></iframe>
    )
  end
end

require 'spec_helper'
require "#{Rails.root}/app/models/collection.rb"
require "#{Rails.root}/app/models/collection_property.rb"


RSpec.describe MetadataHelper, :type => :helper do

  describe "metadata_helper test" do

    before :each do
      # @collection = create(:collection)

      @collection_name = "mycollection"
      @json_str = %({
"@context":
  {"commonProperties":"dada:commonProperties",
   "dada":"purl:dada/schema/0.2#",
   "type":"dada:type",
   "start":"dada:start",
   "end":"dada:end",
   "label":"dada:label",
   "alveo":"http://alveo.edu.au/schema/",
   "ace":"http://ns.ausnc.org.au/schemas/ace/",
   "ausnc":"http://ns.ausnc.org.au/schemas/ausnc_md_model/",
   "austalk":"http://ns.austalk.edu.au/",
   "austlit":"http://ns.ausnc.org.au/schemas/austlit/",
   "bibo":"purl:ontology/bibo/",
   "cooee":"http://ns.ausnc.org.au/schemas/cooee/",
   "dc":"purl:dc/elements/1.1/",
   "foaf":"http://xmlns.com/foaf/0.1/",
   "gcsause":"http://ns.ausnc.org.au/schemas/gcsause/",
   "ice":"http://ns.ausnc.org.au/schemas/ice/",
   "olac":"http://www.language-archives.org/OLAC/1.1/",
   "purl":"http://purl.org/",
   "rdf":"http://www.w3.org/1999/02/22-rdf-syntax-ns#",
   "schema":"http://schema.org/",
   "xsd":"http://www.w3.org/2001/XMLSchema#",
   "marcrel":"http://www.loc.gov/loc.terms/relators/",
   "dcterms":"purl:dc/terms/"},
 "@id":"http://localhost:3000/catalog/mycollection",
 "@type":"dcmitype:Collection",
 "dcterms:abstract":"my collection abstract",
 "dcterms:created":"10/10/2014",
 "dcterms:creator":"Michael Jackson",
 "dcterms:language":"english",
 "dcterms:licence":"MIT",
 "dcterms:title":"myCollectionTitle",
 "marcrel:OWN":"karl",
 "olac:history_of_linguistics":
  "A biography of Ferdinand de Saussure, or an analysis of Plato's discussions on language."
})

      @json = JSON.parse(@json_str)

      @graph_str = %(
@prefix ace: <http://ns.ausnc.org.au/schemas/ace/> .
@prefix alveo: <http://alveo.edu.au/schema/> .
@prefix ausnc: <http://ns.ausnc.org.au/schemas/ausnc_md_model/> .
@prefix austalk: <http://ns.austalk.edu.au/> .
@prefix austlit: <http://ns.ausnc.org.au/schemas/austlit/> .
@prefix bibo: <http://purl.org/ontology/bibo/> .
@prefix cooee: <http://ns.ausnc.org.au/schemas/cooee/> .
@prefix dada: <http://purl.org/dada/schema/0.2#> .
@prefix dc: <http://purl.org/dc/elements/1.1/> .
@prefix dcterms: <http://purl.org/dc/terms/> .
@prefix foaf: <http://xmlns.com/foaf/0.1/> .
@prefix gcsause: <http://ns.ausnc.org.au/schemas/gcsause/> .
@prefix ice: <http://ns.ausnc.org.au/schemas/ice/> .
@prefix marcrel: <http://www.loc.gov/loc.terms/relators/> .
@prefix olac: <http://www.language-archives.org/OLAC/1.1/> .
@prefix olac11: <http://www.language-archives.org/OLAC/1.1/> .
@prefix purl: <http://purl.org/> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix schema: <http://schema.org/> .
@prefix xml: <http://www.w3.org/XML/1998/namespace> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .

<http://localhost:3000/catalog/mycollection> a <dcmitype:Collection> ;
    dcterms:abstract "my collection abstract" ;
    dcterms:created "10/10/2014" ;
    dcterms:creator "Michael Jackson" ;
    dcterms:language "english" ;
    dcterms:licence "MIT" ;
    dcterms:title "myCollectionTitle" ;
    olac:history_of_linguistics "A biography of Ferdinand de Saussure, or an analysis of Plato's discussions on language." ;
    marcrel:OWN "karl" .
      )
      @graph = RDF::Graph.new << RDF::Turtle::Reader.new(@graph_str)
    end

    it 'corpus_dir_by_name' do

      collection = create(:collection)
      expect(MetadataHelper::corpus_dir_by_name(collection.name)).to eq File.join(Rails.application.config.api_collections_location, collection.name)
    end

    it 'create_manifest should create manifest.json with specific json' do

      buffer = StringIO.new

      collection_name = "mycollection"

      corpus_dir = MetadataHelper::corpus_dir_by_name(collection_name)
      filename = File.join(corpus_dir, "manifest.json")
      mode = "w"

      allow(File).to receive(:open).with(filename, mode).and_yield(buffer)

      MetadataHelper::create_manifest(collection_name)

      parsed_json = JSON.parse(buffer.string)

      expect(parsed_json['collection_name']).to eq 'mycollection'

    end


    it "should persist new collection (graph) metadata"  do
      # collection_name = "mycollection"
      collection = Collection.new
      collection.name = @collection_name
      collection.uri = collection_url(@collection_name)
      collection.text = "once upon a time, there was a king"
      collection.private = false
      collection.save

      MetadataHelper::update_rdf_graph(@collection_name, @graph)
      exp_coll = Collection.find_by_name(@collection_name)

      expect(exp_coll.name).to eq(collection.name)
      expect(exp_coll.uri).to eq(collection.uri)
      expect(exp_coll.private).to eq(collection.private)
      expect(exp_coll.text).to eq(collection.text)

      actual_json = MetadataHelper::load_json(collection.name)

      expect(JsonCompare.get_diff(@json, actual_json)).to be_empty

    end

    describe "should update existing collection param" do
      it "update existing param" do
        collection = create(:collection)
        new_text = "never say die!"
        collection.text = new_text
        collection.save

        collection_new = Collection.find_by_name(collection.name)
        expect(collection_new.text).to eq(new_text)
      end
    end

    describe "should update existing collection (graph) metadata"  do
      it "update existing property" do

        collection = Collection.new
        collection.name = @collection_name
        collection.uri = collection_url(@collection_name)
        collection.text = "once upon a time, there was a king"
        collection.private = false
        collection.save

        MetadataHelper::update_rdf_graph(collection.name, @graph)

        ori_json = MetadataHelper::load_json(collection.name)

        property_name = "dcterms:created"
        collection_property = CollectionProperty.where ({:collection_id => collection.id, :property => property_name})

        # expect(collection_property).not_to be_nil
        expect(collection_property.count).to be > 0

        puts "collection_property=(#{collection_property.class}#{collection_property})"

        new_date = "06/04/2016"
        collection_property[0].value = new_date
        collection_property[0].save

        # load collection to check
        actual_json = MetadataHelper::load_json(collection.name)

        # diff = JsonCompare.get_diff(ori_json, actual_json)

        # expect(JsonCompare.get_diff(ori_json, actual_json)).to match_array [[:update, {property_name=>new_date}]]
        expect(JsonCompare.get_diff(ori_json, actual_json)).to include(:update => {property_name => new_date})
      end

      it "add new property" , :focus => true do
        collection = Collection.new
        collection.name = @collection_name
        collection.uri = collection_url(@collection_name)
        collection.text = "once upon a time, there was a king"
        collection.private = false
        collection.save

        MetadataHelper::update_rdf_graph(collection.name, @graph)

        ori_json = MetadataHelper::load_json(collection.name)

        collection_property = CollectionProperty.new
        collection_property.collection_id = collection.id
        collection_property.property = "olac:general_linguistics"
        collection_property.value = "Broad, often introductory textbooks such as The Cambridge Encyclopaedia of Language (Crystal, 1987), and glossaries of linguistic terminology."
        collection_property.save

        # load collection to check
        actual_json = MetadataHelper::load_json(collection.name)

        # diff = JsonCompare.get_diff(ori_json, actual_json)

        expect(JsonCompare.get_diff(ori_json, actual_json)).to include(:append => {collection_property.property => collection_property.value})
      end

      it "remove existing property" do
        collection = Collection.new
        collection.name = @collection_name
        collection.uri = collection_url(@collection_name)
        collection.text = "once upon a time, there was a king"
        collection.private = false
        collection.save

        MetadataHelper::update_rdf_graph(collection.name, @graph)

        ori_json = MetadataHelper::load_json(collection.name)

        property_name = "dcterms:created"
        collection_property = CollectionProperty.where ({:collection_id => collection.id, :property => property_name})

        # expect(collection_property).not_to be_nil
        expect(collection_property.count).to be > 0

        property_value = collection_property[0].value
        collection_property[0].delete

        # load collection to check
        actual_json = MetadataHelper::load_json(collection.name)

        # diff = JsonCompare.get_diff(ori_json, actual_json)

        expect(JsonCompare.get_diff(ori_json, actual_json)).to include(:remove => {property_name=>property_value})
      end


    end

  end
end
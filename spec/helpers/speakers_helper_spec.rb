require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the SpeakersHelper. For example:
#
# describe SpeakersHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe SpeakersHelper, :type => :helper do
  before :each do
    str = %(
{
  "@context": {
    "dcterms": "http://purl.org/dc/terms/",
    "foaf": "http://xmlns.com/foaf/0.1/",
    "olac": "http://www.language-archives.org/OLAC/1.1/",
    "olac11": "http://www.language-archives.org/OLAC/1.1/",
    "rdf": "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
    "rdfs": "http://www.w3.org/2000/01/rdf-schema#",
    "xsd": "http://www.w3.org/2001/XMLSchema#"
  },
  "@id": "http://localhost:3000/speakers/gen_rdf/1_116",
  "dcterms:identifier": "1_116",
  "foaf:age": "45",
  "foaf:gender": "male",
  "olac11:speaker": "http://localhost:3000/speakers/gen_rdf/1_116"
}
    )
    @json = JSON.parse(str)

    @rdf = MetadataHelper.json_to_rdf_graph(@json)

    @context = JSON.parse(%(
      {
        "@context": {
          "dbp": "http://dbpedia.org/ontology/",
          "dcterms": "http://purl.org/dc/terms/",
          "foaf": "http://xmlns.com/foaf/0.1/",
          "geo": "http://www.w3.org/2003/01/geo/wgs84_pos#",
          "iso639": "http://downlode.org/rdf/iso-639/languages#",
          "olac": "http://www.language-archives.org/OLAC/1.1/",
          "rdf": "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
          "rdfs": "http://www.w3.org/2000/01/rdf-schema#",
          "xsd": "http://www.w3.org/2001/XMLSchema#"
        }}))['@context']
  end

  describe "find out correct speaker json format" do
    it "rdf is not nil" do
      expect(@rdf).not_to be_nil
      # puts @rdf.dump(:ntriples)
      puts @rdf.dump(:n3)

      # puts JSON.pretty_generate(MetadataHelper.rdf_graph_to_json(@rdf))
    end

    it "Minimal example, no extra metadata fields" do
      input = JSON.parse %(
      {
        "@context": {
          "dbp": "http://dbpedia.org/ontology/",
          "dcterms": "http://purl.org/dc/terms/",
          "foaf": "http://xmlns.com/foaf/0.1/",
          "geo": "http://www.w3.org/2003/01/geo/wgs84_pos#",
          "iso639": "http://downlode.org/rdf/iso-639/languages#",
          "olac": "http://www.language-archives.org/OLAC/1.1/",
          "rdf": "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
          "rdfs": "http://www.w3.org/2000/01/rdf-schema#",
          "xsd": "http://www.w3.org/2001/XMLSchema#",

          "identifier": "dcterms:identifier",
          "gender": "foaf:gender",
          "age": "foaf:age",
          "birthYear": "dbp:birthYear"
        },

        "identifier": "1_116",
        "birthYear": 1967,
        "gender": "male",
        "age": 45
      })

      json = JSON::LD::API.compact(input, @context)
      expect(json).not_to be_nil

      puts JSON.pretty_generate(json)

      rdf = RDF::Graph.new << JSON::LD::API.toRDF(json)
      str = rdf.dump(:ttl)
      puts str

      CONTEXT_JSON = JSON.parse(%(
      {
        "@context" : {
          "dbp": "http://dbpedia.org/ontology/",
          "dcterms": "http://purl.org/dc/terms/",
          "foaf": "http://xmlns.com/foaf/0.1/",
          "geo": "http://www.w3.org/2003/01/geo/wgs84_pos#",
          "iso639": "http://downlode.org/rdf/iso-639/languages#",
          "olac": "http://www.language-archives.org/OLAC/1.1/",
          "rdf": "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
          "rdfs": "http://www.w3.org/2000/01/rdf-schema#",
          "xsd": "http://www.w3.org/2001/XMLSchema#"
        }
      }))['@context']

      puts CONTEXT_JSON

      context_rdf = Hash[CONTEXT_JSON.map{|k, v| ["PREFIX " + k.gsub('"', '')+":", "<#{v.strip}>"]}]

      puts context_rdf



    #   extract metadata
    end

    it "minimal example with reference to external context" do
      input = JSON.parse %(
      {
        "@context": "http://app.alveo.edu.au/schema/speaker-context",
        "identifier": "1_116",
        "birthYear": 1967,
        "gender": "male",
        "age": 45
      })

      json = JSON::LD::API.compact(input, @context)
      expect(json).not_to be_nil

      puts JSON.pretty_generate(json)
    end

  end
end

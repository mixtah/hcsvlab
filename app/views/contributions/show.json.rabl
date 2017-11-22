#
# {
#	"url" : "https://app.alveo.edu.au/contrib/monash",
#	"name" : "monash",
#	"metadata": {
#		"creator" : "Karl LI",
#		"created" : "2017-11-14 05:41:10 UTC",
#		"abstract" : "Monash Corpus of Spoken English"
#	},
#	"documents" : [
#		{"name" : "1-1.wav", "url": "https://app.alveo.edu.au/catalog/monash/item_1/document/1-1.wav"},
#		{"name" : "1-2.wav", "url" : "https://app.alveo.edu.au/catalog/monash/item_1/document/1-2.wav"}
#	]
# }

object @contribution
attributes :name, :description
node(:url) {|c| contrib_show_url{c.id}}
node(:metadata) {@contribution_metadata}
child @contribution_mapping => :documents do
  node(:name) {|m| m[:document_file_name]}
  node(:url) {|m| catalog_document_url(@contribution.collection.name, m[:item_name], m[:document_file_name])}
end

require 'rake'
SAMPLE_FOLDER = "#{Rails.root}/test/samples"
#
#
#
def ingest_sample(user_email, collection, identifier)

  rdf_file = "#{SAMPLE_FOLDER}/#{collection}/#{identifier}-metadata.rdf"

  rake = Rake::Application.new
  Rake.application = rake
  rake.init
  rake.load_rakefile
  rake["fedora:ingest_one"].invoke(user_email, rdf_file)

  json = {:cmd => "index", :arg => "#{Item.last.id}"}
  Solr_Worker.new.on_message(JSON.generate(json).to_s)
end

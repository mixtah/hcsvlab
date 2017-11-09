require "#{Rails.root}/lib/solr/solr_helper.rb"
# require "#{Rails.root}/app/helpers/metadata_helper.rb"
require 'kramdown'

class Collection < ActiveRecord::Base

  COLLECTION_NAME = :name
  COLLECTION_PRIVATE = :private
  COLLECTION_TEXT = :text
  COLLECTION_URI = :uri

  has_many :items, dependent: :destroy, inverse_of: :collection

  has_many :collection_properties, dependent: :destroy, inverse_of: :collection
  has_many :attachments, dependent: :destroy, inverse_of: :collection

  belongs_to :owner, class_name: 'User', foreign_key: :owner_id
  belongs_to :collection_list
  belongs_to :licence

  scope :not_in_list, where(collection_list_id: nil)
  scope :only_public, where(private: false)
  scope :only_private, where(private: true)

  validates :name, presence: true, uniqueness: {case_sensitive: false}
  validates :uri, presence: true
  # TODO: collection_enhancement at least has 6 standard properties: 5 dcterms, 1 olac
  # validates :collection_properties, length: {minimum: 6}


  def self.sanitise_name(name)
    # Spaces shouldn't be used since Sesame uses the name within the metadata URI
    # . and / shouldn't be used in the name since they can break the routes mapping
    name.downcase.delete(' ./')
  end

  # Returns the directory in which the collection manifest and item metadata files are stored in
  def corpus_dir
    # KL
    # File.join(File.dirname(self.rdf_file_path), self.name)

    # TODO: fix fedora.rake as well
    # File.join(Rails.application.config.api_collections_location, self.name)

    MetadataHelper::corpus_dir_by_name(self.name)
  end

  def set_licence(licence)
    self.licence = licence
    self.save!
  end

  def set_privacy(status)
    self.private = status
    self.save!
  end

  def is_public?
    !private?
  end

  #
  # ===========================================================================
  # Support for adding licences to collections via scripts
  # ===========================================================================
  #

  #
  # Find the collection with the given short name and, as long as we found such
  # a collection, set its licence to the one supplied.
  #
  def self.assign_licence(collection_name, licence)
    # Find the collection
    array = Collection.where(name: collection_name)
    if array.empty?
      Rails.logger.error("Collection.assign_licence: cannot find a collection called #{name}")
      return
    elsif array.size > 1
      Rails.logger.error("Collection.assign_licence: multiples collections called #{name}!")
      return
    end

    collection = array[0]
    collection.set_licence(licence) unless licence.nil?

    Rails.logger.info("Licence #{licence.name} assigned to Collection #{collection.name}") unless licence.nil?
  end
  # End of Support for adding licences to collections via scripts
  # ---------------------------------------------------------------------------
  #

  def rdf_graph
    # raise "Could not find collection metadata file" unless File.exist?(self.rdf_file_path)
    # RDF::Graph.load(self.rdf_file_path, :format => :ttl, :validate => true)

    MetadataHelper::load_rdf_graph(self.name)

  end

  def html_text
    Kramdown::Document.new(text.nil? ? '' : text).to_html
  end

  # TODO: to find associated document by file name, use in contribution
  def find_associated_document_by_file_name

  end
end

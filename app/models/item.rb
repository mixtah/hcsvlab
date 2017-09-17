class Item < ActiveRecord::Base

  has_many :documents, dependent: :destroy

  belongs_to :collection

  validates :uri, presence: true
  validates :collection_id, presence: true

  # validates :handle, presence: true, uniqueness: {case_sensitive: false}
  validates :handle, presence: true, uniqueness: true

  before_save :downcase_handle

  scope :unindexed, where(indexed_at: nil)
  scope :indexed, where('indexed_at is not null')

  def downcase_handle
    self.handle.downcase!
  end
  
  def self.sanitise_name(name)
    # Spaces shouldn't be used since Sesame uses the name within the metadata URI
    # . and / shouldn't be used in the name since they can break the routes mapping
    name.downcase.delete(' ./')
  end

  def has_primary_text?
    self.primary_text_path.present?
  end

  #
  # The list of Item fields which we should not show to the user.
  #
  def self.development_only_fields
    ['id',
     'timestamp',
     'full_text',
     MetadataHelper::short_form(MetadataHelper::RDF_TYPE) + '_tesim',
     'handle',
     '_version_',
     'all_metadata',
     'discover_access_group_ssim',
     'read_access_group_ssim',
     'edit_access_group_ssim',
     'discover_access_person_ssim',
     'read_access_person_ssim',
     'edit_access_person_ssim',
     "json_metadata",
     "score",
     MetadataHelper::short_form(MetadataHelper::DISPLAY_DOCUMENT) + '_tesim',
     MetadataHelper::short_form(MetadataHelper::INDEXABLE_DOCUMENT) + '_tesim']
  end

  #
  # Returns the item name
  #
  def get_name
    self.handle.split(':').last
  end


  #
  # Returns the format of the item handle for the given collection and item name
  #
  def self.format_handle(collection_name, item_name)
    "#{collection_name}:#{item_name}"
  end
end

class Attachment < ActiveRecord::Base
  before_save :update_attributes

  attr_accessible :file, :file_name, :content_type, :file_size, :created_by, :collection_id

  # remember to set in front end as well
  validates :file, file_size: {less_than: 100.megabyte}

  belongs_to :collection

  # validates :file_name, presence: true
  # validates :content_type, presence: true
  # validates :file_size, presence: true
  # validates :created_by, presence: true

  mount_uploader :file, AttachmentUploader

  def self::by_collection(collection_id)
    logger.debug "Attachment:by_collection collection_id=#{collection_id}"
    Attachment.where('collection_id' => collection_id)
  end

  def update_attributes
    # logger.debug "Attachment:update_attributes collection_id=#{self.collection_id}"
    # logger.debug "Attachment:update_attributes file=#{file}"

    if file.present? && file_changed?
      self.file_name = file.file.filename
      self.content_type = file.file.content_type
      self.file_size = file.file.size

      logger.debug "Attachment:update_attributes attachment=#{self.to_jq_upload}"
    end
  end

  def to_jq_upload
    {
        "name" => self.file_name,
        "size" => self.file_size,
        "url" => file.url,
        "thumbnail_url" => file.thumb.url,
        "delete_url" => "/attachments/#{id}",
        "delete_type" => "DELETE"
    }
  end

  # errors_messages is from validation Errors[:file]
  def to_jq_error(errors)
    {
        "error" => errors[:file],
        "name" => self.file_name,
        "size" => self.file_size,
        "url" => '',
        "thumbnail_url" => '',
        "delete_url" => '',
        "delete_type" => "DELETE"
    }
  end

  def store_dir
    logger.debug "Attachment:store_dir collection_id=#{self.collection_id}"
    # MetadataHelper::corpus_dir_by_name(Collection.find(self.collection_id).name)
    Rails.root.join("public", "collections", self.collection_id.to_s)
  end
end
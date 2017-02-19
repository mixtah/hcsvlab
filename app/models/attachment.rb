require 'set'

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
        "thumbnail_url" => file_icon(file.thumb.url),
        # "icon" => file_icon(file.thumb.url),
        "delete_url" => "/attachments/#{id}",
        "delete_type" => "DELETE"
    }
  end

  def file_icon(file_name)

    rlt = nil
    # \.        # match a literal dot
    # [^.]+     # match 1 or more of any character but dot
    # $         # anchor to match end of input
    file_ext = file_name.downcase[/\.[^.]+$/]

    img_ext_set = %w(.jpeg .jpg .png .gif .bmp).to_set

    if img_ext_set.include?(file_ext)
      #   image file has thumb nail, no icon needed
      rlt = file_name
    else
      ext_set = %w(.3gp .7z .ace .ai .aif .aiff .amr .asf .asx .bat .bin .bmp .bup .cab .cbr .cda .cdl .cdr .chm .dat .divx .dll .dmg .doc .dss .dvf .dwg .eml .eps .exe .fla .flv .gif .gz .hqx .htm .html .ifo .indd .iso .jar .jpeg .jpg .lnk .log .m4a .m4b .m4p .m4v .mcd .mdb .mid .mov .mp2 .mp4 .mpeg .mpg .msi .mswmm .ogg .pdf .png .pps .ps .psd .pst .ptb .pub .qbb .qbw .qxd .ram .rar .rm .rmvb .rtf .sea .ses .sit .sitx .ss .swf .tgz .thm .tif .tmp .torrent .ttf .txt .vcd .vob .wav .wma .wmv .wps .xls .xpi .zip).to_set

      icon = '.unknown'

      unless file_ext.nil?
        icon = file_ext if ext_set.include?(file_ext)
      end

      rlt = '/assets/fileicons/file_extension_' + icon[1..-1] + '.png'
    end

    logger.debug "Attachment.file_icon file_name=#{file_name}, rlt=#{rlt}"

    rlt
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
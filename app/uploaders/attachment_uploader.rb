# encoding: utf-8
# require 'carrierwave/processing/mime_types'

class AttachmentUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  include CarrierWave::MimeTypes
  process :set_content_type

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    # "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    "#{model.store_dir}/attachments/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  # process resize_to_fit: [200, 300]

  # def scale(width, height)
  #   process resize_to_fit: [width, height]
  # end

  # Create different versions of your uploaded files:
  version :thumb do
    process :resize_to_fit => [50, 50], :if => :image?
    # process :pdf_preview => [50, 50], :if => :pdf?
    # process :get_geometry

    # We need to change the extension for PDF thumbnails to '.jpg'
    # def full_filename(filename)
    #   filename = File.replace_extension(filename, '.jpg') if File.extname(filename)=='.pdf'
    #   "thumb_#{filename}"
    # end
  end


  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_white_list
  #   %w(jpg jpeg gif png pdf txt json)
  # end
  # Extensions which are allowed to be uploaded.
  # def extension_white_list
  #   %w(jpg jpeg gif png bmp pdf doc docx txt mp3 xls xlsx n3)
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

  private

  # def thumbable?(file)
  #   image?(file)
  # end

  def image?(file)
    # Check the model first (see https://github.com/carrierwaveuploader/carrierwave/issues/1315)
    # return model.is_image? if model.content_type.present?
    file.content_type.include? 'image'
  end

  # def pdf?(file)
  #   # Check the model first (see https://github.com/carrierwaveuploader/carrierwave/issues/1315)
  #   # return model.is_pdf? if model.content_type.present?
  #   file.content_type == 'application/pdf'
  # end

  # def get_geometry
  #   if (@file)
  #     img = ::Magick::Image::read(@file.file).first
  #     @geometry = {:width => img.columns, :height => img.rows}
  #   end
  # end

end

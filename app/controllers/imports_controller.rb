require "#{Rails.root}/lib/zip_importer"

class ImportsController < ApplicationController

  STOMP_CONFIG = YAML.load_file("#{Rails.root.to_s}/config/broker.yml")[Rails.env] unless defined? STOMP_CONFIG
  PREVIEW_LIMIT = 20
  
  before_filter :authenticate_user!
  set_tab :collection

  def edit
    @import = Import.find(params[:id])
    @collection = @import.collection
    authorize! :web_add_item, @import.collection

    @additional_metadata = JSON.parse(@import.metadata) rescue []

    @options = JSON.parse(@import.options) rescue {}
    @metadata = JSON.parse(@import.metadata) rescue []

    @zip = AlveoUtil::ZipImporter.new(@import.directory, @import.filename, @options)

    @docs = @zip.find_documents
    @item_metadata = @zip.item_metadata
    @item_metadata_fields = @zip.item_metadata_fields
    @size = @zip.items.size
    @limit = [ 20, @size ].min
  end

  def update
    @import = Import.find(params[:id])
    @collection = @import.collection
    authorize! :web_add_item, @import.collection

    @options = JSON.parse(@import.options) rescue {}
    @options[:folders_as_item_names] = !!params[:option_folders_as_item_names]
    @options[:item_name_at_folder_depth] = (params[:option_item_name_at_folder_depth].to_i > 0) ? params[:option_item_name_at_folder_depth].to_i : nil

    @options[:meta_in_filename] = !!params[:option_meta_in_filename]
    @options[:meta_delimiter]  = (@options[:meta_in_filename] && !params[:option_meta_delimiter].blank?) ? params[:option_meta_delimiter] : nil
    @options[:num_meta_fields] = (@options[:meta_in_filename] && params[:option_num_meta_fields].to_i > 0) ? params[:option_num_meta_fields].to_i : nil
    @options[:meta_fields]     = (@options[:meta_in_filename] && params[:option_meta_fields].is_a?(Array) && params[:option_meta_fields].size > 0) ? params[:option_meta_fields] : []

    @import.options = @options.to_json
    @import.save

    if params[:commit] == "Confirm import"
      # TODO do it
    else
      redirect_to edit_import_path(@import)
    end
  end

  def show
    @import = Import.find(params[:id])
    redirect_to edit_import_path(@import)
  end

  def create
    @collection = Collection.find_by_name(params[:collection_id])
    authorize! :web_add_item, @collection

    begin
      uploaded_io = params[:zip_file]
      now_dir = Time.now.to_f.to_s
      upload_dir = File.join(Rails.application.config.upload_location, now_dir)
    
      # Save the uploaded file into our upload dir
      FileUtils.mkdir_p(upload_dir)
      File.open(File.join(upload_dir, uploaded_io.original_filename), 'wb') do |file|
        # no .eof? method available in this version of ActionDispatch
        # file.write(uploaded_io.read(2**16)) until uploaded_io.eof?
        # 
        # So this will fall over at a certain size, not sure what
        file.write(uploaded_io.read)
      end

      # Save the metadata to a json file to the same dir
      metadata = []
      if params.has_key?(:additional_key) && params.has_key?(:additional_value)
          metadata = zip_metadata(params[:additional_key], params[:additional_value]) 
      end

      @import = Import.new
      @import.collection = @collection
      @import.user = current_user
      @import.directory = upload_dir
      @import.filename = uploaded_io.original_filename
      @import.metadata = metadata.to_json
      @import.extracted = false
      @import.save!

      stomp_client = Stomp::Client.open "#{STOMP_CONFIG['adapter']}://#{STOMP_CONFIG['host']}:#{STOMP_CONFIG['port']}"
      
      packet = {
        :cmd => "import_zip",
        :arg => {
          :import_id => @import.id
        }
      }
      
      stomp_client.publish('alveo.solr.worker', packet.to_json)
      stomp_client.close

      msg = "Your zip file has been uploaded. It will be processed shortly."
      redirect_to edit_import_path(@import), notice: msg

    rescue Exception => e
      flash[:error] = e.message
      redirect_to new_collection_import_path(:collection => @collection)
    end
  end

  # GET /collections/:collectionName/import/new
  # 
  def new
    @collection = Collection.find_by_name(params[:collection_id])
    authorize! :web_add_item, @collection

    @import = Import.new
    
    # Default metadata to fill form
    if !params.has_key?(:additional_key) && !params.has_key?(:additional_value)
      params[:additional_key] = [
        'ausnc:mode',
        'ausnc:speech_style',
        'ausnc:interactivity',
        'ausnc:communication_context',
        'ausnc:audience',
      ]
      params[:additional_value] = [
        'spoken',
        'scripted',
        'dialog',
        'face_to_face',
        'individual',
      ]
      @additional_metadata = zip_metadata(params[:additional_key], params[:additional_value])
    end
  end

  def zip_metadata(meta_field_names, meta_field_values)
    if meta_field_names.nil? || meta_field_values.nil?
      []
    else
      meta_field_names.zip(meta_field_values)
    end
  end
end

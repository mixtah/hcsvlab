require Rails.root.join('lib/tasks/fedora_helper.rb')
require Rails.root.join('lib/api/response_error')
require Rails.root.join('lib/api/request_validator')
require Rails.root.join('lib/json-ld/json_ld_helper.rb')
require Rails.root.join('app/helpers/metadata_helper')
require Rails.root.join('app/helpers/items_helper')

# require 'metadata_helper'
require 'fileutils'

class CollectionsController < ApplicationController

  STOMP_CONFIG = YAML.load_file("#{Rails.root.to_s}/config/broker.yml")[Rails.env] unless defined? STOMP_CONFIG

  # include MetadataHelper

  # Don't bother updating _sign_in_at fields for every API request 
  prepend_before_filter :skip_trackable # , only: [:add_items_to_collection, :add_document_to_item]
  before_filter :authenticate_user!, except: [:index, :show]

  #load_and_authorize_resource
  load_resource :only => [:create]
  skip_authorize_resource :only => [:create] # authorise create method with custom permission denied error

  set_tab :collection

  include RequestValidator
  include ItemsHelper

  PER_PAGE_RESULTS = 20
  #
  #
  #
  def index
    @collections = collections_by_name

    respond_to do |format|
      format.html
      format.json
    end
  end

  def show

    @collection = Collection.find_by_name(params[:id])

    if @collection.nil? || @collection.name.nil?
      respond_to do |format|
        format.html {
          flash[:error] = "Collection does not exist with the given id: #{params[:id]}"
          redirect_to collections_path}
        format.json {render :json => {:error => "not-found"}.to_json, :status => 404}
      end
    else
      @attachment_url = collection_attachments_path(@collection.id)

      respond_to do |format|
        format.html {render :show}
        format.json {}
      end
    end
  end

  def create
    authorize! :create, @collection,
               :message => "Permission Denied: Your role within the system does not have sufficient privileges to be able to create a collection. Please contact an Alveo administrator."
    collection_metadata = params[:collection_metadata]
    collection_name = params[:name]
    licence_id = params[:licence_id].present? ? params[:licence_id] : nil
    privacy = true
    privacy = (params[:private].to_s.downcase == 'true') unless params[:private].nil?
    owner = User.find_by_authentication_token(params[:api_key])
    begin
      validate_new_collection(collection_metadata, collection_name, licence_id, privacy)
      @success_message = create_collection_core(Collection.sanitise_name(collection_name), collection_metadata, owner, licence_id, privacy)
    rescue ResponseError => e
      respond_with_error(e.message, e.response_code)
      return # Only respond with one error at a time
    end
  end

  #
  # List all collections by name (include collection in collection_list)
  #
  def collections_by_name
    Collection.order(:name)
  end

  def lists_by_name
    CollectionList.order(:name)
  end

  def new
  end

  #
  #
  #
  def add_licence_to_collection
    collection = Collection.find(params[:collection_id])
    licence = Licence.find(params[:licence_id])

    collection.set_licence(licence)

    flash[:notice] = "Successfully added licence to #{collection.name}"
    redirect_to licences_path(:hide => (params[:hide] == true.to_s) ? "t" : "f")
  end

  #
  #
  #
  def change_collection_privacy
    collection = Collection.find(params[:id])
    private = params[:privacy]
    collection.set_privacy(private)
    if private=="false"
      UserLicenceRequest.where(:request_id => collection.id.to_s).destroy_all
    end
    private=="true" ? state="requiring approval" : state="not requiring approval"
    flash[:notice] = "#{collection.name} has been successfully marked as #{state}"
    redirect_to licences_path
  end

  #
  #
  #
  def revoke_access
    collection = Collection.find(params[:id])
    UserLicenceRequest.where(:request_id => collection.id.to_s).destroy_all if collection.private?
    UserLicenceAgreement.where(name: collection.name, collection_type: 'collection').destroy_all
    flash[:notice] = "All access to #{collection.name} has been successfully revoked"
    redirect_to licences_path
  end

  def web_create_collection
    authorize! :web_create_collection, Collection
    # Expose public licences and user created licences

    @collection_name = params[:collection_name]
    @collection_title = params[:collection_title]
    @collection_owner = params[:collection_owner]
    @collection_text = params[:collection_text]
    @collection_abstract = params[:collection_abstract]
    @approval_required = params[:approval_required]
    @approval_required = 'private' if request.get?
    @licence_id = params[:licence_id]
    @additional_metadata = zip_additional_metadata(params[:additional_key], params[:additional_value])

    # mandatory params
    @collection_language = params[:collection_language]
    @collection_language = 'eng - English' if @collection_language.nil?
    @collection_languages = Language.all.collect {|l| ["#{l.code} - #{l.name}", "#{l.code} - #{l.name}"]}
    #
    #
    @collection_creation_date = params[:collection_creation_date]
    @collection_creator = params[:collection_creator]

    # no default olac subject
    @olac_subject = params[:olac_subject].nil? ? "" : params[:olac_subject]

    @collection_licences = licences

    if request.get?

      @collection_name = nil
      @collection_title = nil
      @collection_creation_date = nil
      @collection_creator = nil
      @collection_owner = nil
      @collection_abstract = nil
      @collection_text = nil

      #   load content only for Get
      @olac_subject_options = MetadataHelper::OLAC_LINGUISTIC_SUBJECT_HASH

      @additional_metadata = {}
      @additional_metadata_options = metadata_names_mapping

    end

    if request.post?
      begin
        validate_required_web_fields(
          params,
          {
            :collection_name => 'collection name'
            # :collection_title => 'collection title',
            # :collection_language => 'collection language',
            # :collection_creation_date => 'collection creation date',
            # :collection_creator => 'collection creator',
            # :collection_owner => 'collection owner',
            # :collection_olac_name => 'collection OLAC linguistic subject',
            # :collection_olac_value => 'collection OLAC linguistic subject value',
            # :collection_abstract => 'collection abstract'
            # :collection_text => 'collection description'
          }
        )

        # Validate and sanitise OLAC metadata fields
        # olac_metadata = validate_collection_olac_metadata(params)

        # logger.debug "olac_metadata=#{olac_metadata}"

        # Validate and sanitise additional metadata fields
        additional_metadata = validate_collection_additional_metadata(params)

        # retrieve valid licence
        lic = licence(@licence_id)

        # Construct collection Json-ld
        json_ld = {
          '@context' => JsonLdHelper::default_context,
          '@type' => 'dcmitype:Collection',
          MetadataHelper::LOC_OWNER.to_s => @collection_owner,
          MetadataHelper::LICENCE.to_s => (lic ? lic.name : ""),
          MetadataHelper::OLAC_SUBJECT.to_s => @olac_subject,
          MetadataHelper::ABSTRACT.to_s => @collection_abstract
        }

        # json_ld.merge!(olac_metadata) { |key, val1, val2| val1 }

        json_ld.merge!(additional_metadata) {|key, val1, val2| val1}

        # Ingest new collection
        name = Collection.sanitise_name(params[:collection_name])
        msg = create_collection_core(
          name,
          json_ld,
          current_user,
          (lic ? lic.id : nil),
          @approval_required == 'private',
          @collection_text)

        redirect_to collection_path(id: name), notice: msg
      rescue ResponseError => e
        flash[:error] = e.message
      end
    end
  end

  def add_items_to_collection
    # referenced documents (HCSVLAB-1019) are already handled by the look_for_documents part of the item ingest
    logger.debug "collectios#add_items_to_collection"

    begin
      request_params = cleanse_params(params)
      collection = validate_collection(request_params[:id], request_params[:api_key])
      # ToDo: sanitise each item name (dc:identifier) once the new JSON-LD format is completed
      validate_add_items_request(collection, collection.corpus_dir, request_params[:items], request_params[:file])
      request_params[:items].each do |item_json|
        update_ids_in_jsonld(item_json["metadata"], collection)
      end
      uploaded_files = process_uploaded_files(collection.corpus_dir, collection.name, request_params[:file])
      processed_items = process_items(collection.name, collection.corpus_dir, request_params, uploaded_files)
      @success_message = add_item_core(collection, processed_items[:successes])
    rescue ResponseError => e
      respond_with_error(e.message, e.response_code)
      return # Only respond with one error at a time
    end
  end

  def web_add_item
    @collection = Collection.find_by_name(params[:id])
    authorize! :web_add_item, @collection
    @item_name = params[:item_name]
    @item_title = params[:item_title]
    @additional_metadata = zip_additional_metadata(params[:additional_key], params[:additional_value])
    if request.post?
      begin
        # Raise an exception if required fields are empty
        validate_required_web_fields(params, {:item_name => 'item name', :item_title => 'item title'})

        # Raise an exception if item is not unique in the collection
        item_name = validate_item_name_unique(@collection, Item.sanitise_name(params[:item_name]))

        msg = add_item(params, item_name, @collection)
        msg = "Created new item: #{msg.first}" # Format the item creation message

        redirect_to catalog_path(collection: @collection.name, itemId: item_name), notice: msg
      rescue ResponseError => e
        flash[:error] = e.message
      end
    end
  end

  def add_document_to_item
    begin
      collection = validate_collection(params[:collectionId], params[:api_key])
      item = validate_item_exists(collection, params[:itemId])
      doc_metadata = parse_str_to_json(params[:metadata], 'JSON document metadata is ill-formatted')

      logger.debug "add_document_to_item: params[:metadata]=#{params[:metadata]}, doc_metadata[#{doc_metadata}]"

      doc_content = params[:document_content]
      uploaded_file = params[:file]
      uploaded_file = uploaded_file.first if uploaded_file.is_a? Array
      doc_filename = MetadataHelper::get_dc_identifier(doc_metadata) # the document filename is the document id
      doc_metadata = format_and_validate_add_document_request(collection.corpus_dir, collection, item, doc_metadata, doc_filename, doc_content, uploaded_file)
      @success_message = add_document_core(collection, item, doc_metadata, doc_filename)
    rescue ResponseError => e
      respond_with_error(e.message, e.response_code)
      return # Only respond with one error at a time
    end
  end

  def web_add_document
    collection = Collection.find_by_name(params[:collection])
    authorize! :web_add_document, collection

    @language = params[:language]
    @language = 'eng - English' if @language.nil?
    @languages = Language.all.collect {|l| ["#{l.code} - #{l.name}", "#{l.code} - #{l.name}"]}
    @additional_metadata = zip_additional_metadata(params[:additional_key], params[:additional_value])
    if request.post?
      item = Item.find_by_handle(Item.format_handle(collection.name, params[:itemId]))
      uploaded_file = params[:document_file]
      begin
        validate_required_web_fields(params, {:document_file => 'document file', :language => 'language'})
        validate_new_document_file(collection.corpus_dir, uploaded_file.original_filename, collection)
        additional_metadata = validate_document_additional_metadata(params)
        uploaded_file_path = upload_document_using_multipart(collection.corpus_dir, uploaded_file.original_filename, uploaded_file, collection.name)
        json_ld = construct_document_json_ld(collection, item, params[:language], uploaded_file_path, additional_metadata)
        msg = add_document_core(collection, item, json_ld, uploaded_file_path)
        redirect_to catalog_path(collection: collection.name, itemId: item.get_name), notice: msg
      rescue ResponseError => e
        flash[:error] = e.message
      end
    end
  end

  def delete_item_from_collection
    begin
      collection = validate_collection(params[:collectionId], params[:api_key])
      item = validate_item_exists(collection, params[:itemId])
      @success_message = delete_item_core(item)
    rescue ResponseError => e
      respond_with_error(e.message, e.response_code)
      return # Only respond with one error at a time
    end
  end

  def delete_item_via_web_app
    authorize! :delete_item_via_web_app, Collection.find_by_name(params[:collectionId])
    item = Item.find_by_handle(Item.format_handle(params[:collectionId], params[:itemId]))
    begin
      msg = delete_item_core(item)
      redirect_to catalog_index_path, notice: msg
    rescue ResponseError => e
      flash[:error] = e.message
    end
  end

  def delete_item_core(item)
    remove_item(item, item.collection)
    "Deleted the item #{item.get_name} (and its documents) from collection #{item.collection.name}"
  end

  def delete_document_from_item
    begin
      collection = validate_collection(params[:collectionId], params[:api_key])
      item = validate_item_exists(collection, params[:itemId])
      document = validate_document_exists(item, params[:filename])
      @success_message = delete_doc_core(collection, item, document)
    rescue ResponseError => e
      respond_with_error(e.message, e.response_code)
      return # Only respond with one error at a time
    end
  end

  def delete_doc_core(collection, item, document)
    remove_document(document, collection)
    delete_item_from_solr(item.id)
    item.indexed_at = nil
    item.save
    update_item_in_solr(item)
    "Deleted the document #{params[:filename]} from item #{params[:itemId]} in collection #{params[:collectionId]}"
  end

  def delete_document_via_web_app
    authorize! :delete_document_via_web_app, Collection.find_by_name(params[:collectionId])
    begin
      item = Item.find_by_handle(Item.format_handle(params[:collectionId], params[:itemId]))
      collection = item.collection
      document = item.documents.find_by_file_name(params[:filename])
      msg = delete_doc_core(collection, item, document)
      redirect_to catalog_path(params[:collectionId], params[:itemId]), notice: msg
    rescue ResponseError => e
      Rails.logger.error e.message
      flash[:error] = e.message
    end
  end

  # TODO: collection_enhancement
  # def edit_collection
  #   begin
  #     collection = validate_collection(params[:id], params[:api_key])
  #
  #
  #     validate_jsonld(params[:collection_metadata])
  #     new_metadata = format_update_collection_metadata(collection, params[:collection_metadata], params[:replace])
  #     # write_metadata_graph(new_metadata, collection.rdf_file_path, format=:ttl)
  #     MetadataHelper::update_rdf_graph(collection.name, new_metadata)
  #
  #     @success_message = "Updated collection #{collection.name}"
  #   rescue ResponseError => e
  #     respond_with_error(e.message, e.response_code)
  #     return # Only respond with one error at a time
  #   end
  # end

  def edit_collection
    authorize! :edit_collection, Collection

    @collection = Collection.find_by_name(params[:id])

    if @collection.nil?
      raise ResponseError.new(404), "A collection with the name '#{params[:id]}' not exist."
    end

    @collection_licences = licences

    # mandatory collection properties
    properties = {}
    exclude_prop = ['@context', '@type', '@id', MetadataHelper::PFX_LICENCE]
    @collection.collection_properties.each do |prop|
      # use array to store multi value
      unless exclude_prop.include?(prop.property)
        if properties.key?(prop.property)
          #   multi value?
          value = properties[prop.property]
          if value.is_a? (Array)
            properties[prop.property] = (value << prop.value)
          else
            properties[prop.property] = (Array.new([value]) << prop.value)
          end
        else
          properties[prop.property] = prop.value
        end
      end
    end

    @collection_title = properties.delete(MetadataHelper::PFX_TITLE)
    @collection_owner = properties.delete(MetadataHelper::PFX_OWNER)
    @collection_language = properties.delete(MetadataHelper::PFX_LANGUAGE)
    @collection_languages = Language.all.map {|l| ["#{l.code} - #{l.name}", "#{l.code} - #{l.name}"]}.to_h

    if @collection_language.nil?
      @collection_language = 'eng - English'
    else
      unless @collection_languages.key?(@collection_language)
        #   no such lang, need to append
        @collection_languages[@collection_language] = @collection_language
      end
    end

    @collection_creation_date = properties.delete(MetadataHelper::PFX_CREATION_DATE)
    @collection_creator = properties.delete(MetadataHelper::PFX_CREATOR)
    @collection_abstract = properties.delete(MetadataHelper::PFX_ABSTRACT)

    # olac subject
    @olac_subject = properties.delete(MetadataHelper::PFX_OLAC_SUBJECT)
    @olac_subject_options = MetadataHelper::OLAC_LINGUISTIC_SUBJECT_HASH

    # additional metadata
    # OK, all basic metadata gone, so only additional metadata left
    @additional_metadata = properties
    @additional_metadata_options = metadata_names_mapping

    #   attachment url
    @attachment = Attachment.new({collection_id: @collection.id})
    @attachment_url = new_attachment_url(@collection)
  end

  def licences
    licence_table = Licence.arel_table
    Licence.where(licence_table[:private].eq(false).or(licence_table[:owner_id].eq(current_user.id)))
  end

  #
  # Update collection
  #
  def update_collection
    authorize! :update_collection, Collection

    name = Collection.sanitise_name(params[:id])

    begin

      lic = licence(params[:licence_id])

      # logger.debug "olac_metadata=#{olac_metadata}"

      # Validate and sanitise additional metadata fields
      additional_metadata = validate_collection_additional_metadata(params)
      logger.debug "update_collection: additional_metadata=#{additional_metadata}"

      # Construct collection Json-ld
      json_ld = {
        '@context' => JsonLdHelper::default_context,
        '@type' => 'dcmitype:Collection',
        MetadataHelper::TITLE.to_s => params[:collection_title].nil? ? '' : params[:collection_title],
        MetadataHelper::LANGUAGE.to_s => params[:collection_language].nil? ? '' : params[:collection_language],
        MetadataHelper::CREATED.to_s => params[:collection_creation_date].nil? ? '' : params[:collection_creation_date],
        MetadataHelper::CREATOR.to_s => params[:collection_creator].nil? ? '' : params[:collection_creator],
        MetadataHelper::LOC_OWNER.to_s => params[:collection_owner].nil? ? '' : params[:collection_owner],
        MetadataHelper::OLAC_SUBJECT.to_s => params[:olac_subject].nil? ? '' : params[:olac_subject],
        MetadataHelper::LICENCE.to_s => lic.name,
        MetadataHelper::ABSTRACT.to_s => params[:collection_abstract].nil? ? '' : params[:collection_abstract]
      }

      # json_ld.merge!(olac_metadata) { |key, val1, val2| val1 }

      json_ld.merge!(additional_metadata) {|key, val1, val2| val1}

      # Ingest new collection
      # name = Collection.sanitise_name(params[:collection_name])

      msg = create_collection_core(name, json_ld, current_user, lic.id, @approval_required == 'private', params[:collection_text])
      redirect_to collection_path(id: name), notice: msg
    rescue ResponseError => e
      flash[:error] = e.message
      logger.error "update_collection: collection name: #{name}, #{e.message}"

      redirect_to edit_collection_path(id: name)
    end

  end

  def delete_collection
    authorize! :delete_collection, Collection

    collection = Collection.find_by_name(params[:id])

    if collection.nil?
      raise ResponseError.new(404), "A collection with the name '#{params[:id]}' not exist."
    end

    name = collection.name
    corpus_dir = collection.corpus_dir

    # TODO: delete sesame & solr

    unless collection.destroy.nil?
      # unless collection.nil?
      #   delete directory as well
      # corpus_dir = MetadataHelper::corpus_dir_by_name(name)
      logger.debug "remove directory #{corpus_dir}"
      FileUtils.remove_dir(corpus_dir, true)

      flash[:notice] = "Collection with the name '#{name} has been removed successfully.'"
      redirect_to :collections
    end

  end

  def update_item
    begin
      collection = validate_collection(params[:collectionId], params[:api_key])
      item = validate_item_exists(collection, params[:itemId])
      validate_jsonld(params[:metadata])
      new_metadata = format_update_item_metadata(item, params[:metadata])
      update_item_in_sesame(new_metadata, collection)
      update_item_in_solr(item)
      @success_message = "Updated item #{item.get_name} in collection #{collection.name}"
    rescue ResponseError => e
      respond_with_error(e.message, e.response_code)
      return # Only respond with one error at a time
    end
  end

  private

  #
  # Creates the model for blacklight pagination.
  #
  #def create_pagination_structure(params)
  #  start = (params[:page].nil?)? 0 : params[:page].to_i-1
  #  total = @collections.length
  #
  #  per_page = (params[:per_page].nil?)? PER_PAGE_RESULTS : params[:per_page].to_i
  #  per_page = PER_PAGE_RESULTS if per_page < 1
  #
  #  current_page = (start / per_page).ceil + 1
  #  num_pages = (total / per_page.to_f).ceil
  #
  #  total_count = total
  #
  #  @collections = @collections[(current_page-1)*per_page..current_page*per_page-1]
  #
  #  start_num = start + 1
  #  end_num = start_num + @collections.length - 1
  #
  #  @paging = OpenStruct.new(:start => start_num,
  #                           :end => end_num,
  #                           :per_page => per_page,
  #                           :current_page => current_page,
  #                           :num_pages => num_pages,
  #                           :limit_value => per_page, # backwards compatibility
  #                           :total_count => total_count,
  #                           :first_page? => current_page > 1,
  #                           :last_page? => current_page < num_pages
  #  )
  #end

  def skip_trackable
    request.env['devise.skip_trackable'] = true
  end

end

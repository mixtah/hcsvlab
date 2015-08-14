class CollectionsController < ApplicationController
  before_filter :authenticate_user!
  #load_and_authorize_resource

  set_tab :collection

  PER_PAGE_RESULTS = 20

  #
  #
  #
  def index
    @collections = collections_by_name
    @collection_lists = lists_by_name
    respond_to do |format|
      format.html
      format.json
    end
  end

  #
  #
  #
  def show
    @collections = collections_by_name
    @collection_lists = lists_by_name

    @collection = Collection.find_by_name(params[:id])
    respond_to do |format|
      if @collection.nil? or @collection.name.nil?
        format.html { 
            flash[:error] = "Collection does not exist with the given id"
            redirect_to collections_path }
        format.json { render :json => {:error => "not-found"}.to_json, :status => 404 }
      else
        format.html { render :index }
        format.json {}
      end
    end
  end

  def create
    if request.format == 'json' and request.post?
      name = params[:name]
      if (!name.nil? and !name.blank? and !(name.length > 255) and !(params[:collection_metadata].nil?))
        @collection = Collection.new
        @collection.name = name
        # Parse JSON-LD formatted collection metadata, convert to RDF and save to .n3 file
        json_md = params[:collection_metadata]
        graph = RDF::Graph.new << JSON::LD::API.toRdf(json_md)
        rdf = graph.dump(:ttl, prefixes: {foaf: "http://xmlns.com/foaf/0.1/"})
        file_path = File.join(Rails.root.to_s, '/data/collections/',  @collection.name + '.n3')
        #TODO: include some kind of validation to ensure existing collections are not overwritten
        f = File.open(file_path, 'w')
        f.puts rdf
        f.close
        @collection.rdf_file_path = file_path
        @collection.save
      else
        invalid_name = name.nil? or name.blank? or name.length > 255
        invalid_metadata = params[:collection_metadata].nil?
        err_message = "name parameter" if invalid_name
        err_message = "metadata parameter" if invalid_metadata
        err_message = "name and metadata" if invalid_name and invalid_metadata
        err_message << " not found" if !err_message.nil?
        respond_to do |format|
          format.any { render :json => {:error => err_message}.to_json, :status => 400 }
        end
      end
    else
      #TODO: handle case when a non JSON POST request is sent
      # name = params[:name]
      # @collection = Collection.find_or_initialize_by_name(name)
      # if @collection.new_record?
      #   if @collection.save
      #     flash[:notice] = 'Collection created successfully'
      #     redirect_to @collection and return
      #   end
      #   flash[:error] = "Error trying to create an Item list, name too long (max. 255 characters)" if (name.length > 255)
      #   flash[:error] = "Error trying to create an Item list" unless (name.length > 255)
      #   redirect_to :back and return
      # else
      #   flash[:error] = "Collection with name '#{name}' already exists."
      #   redirect_to :back and return
      # end
    end
  end

  def collections_by_name
    Collection.not_in_list.order(:name)
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
    redirect_to licences_path(:hide=>(params[:hide] == true.to_s)?"t":"f")
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

end

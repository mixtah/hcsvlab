# class AttachmentsController < SimpleApplicationController
class AttachmentsController < ActionController::Base
  # GET /collections/:collection_id/attachments
  # GET /collections/:collection_id/attachments.json
  def index
    logger.debug "attachments#index collection_id=#{params[:collection_id]}"

    @attachments = attachments_by_collection(params[:collection_id])

    respond_to do |format|
      format.html # index.html.erb
      # format.json { render json: @attachments }
      format.json { render json: @attachments.map { |a| a.to_jq_upload } }
    end
  end

  # GET /collections/:collection_id/attachments/:id
  # GET /collections/:collection_id/attachments/:id.json
  def show
    @attachment = Attachment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @attachment }
    end
  end

  # GET /collections/:collection_id/attachments/new
  # GET /collections/:collection_id/attachments/new.json
  def new
    logger.debug "attachments#new collection_id=#{params[:collection_id]}"
    # collection = Collection.find(params[:collection_id])
    @attachment = Attachment.new({collection_id: params[:collection_id]})

    logger.debug "attachments#new attachment=#{@attachment}"

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @attachment }
    end
  end

  # GET /collections/:collection_id/attachments/:id/edit
  def edit
    @attachment = Attachment.find(params[:id])
  end

  # POST /collections/:collection_id/attachments
  # POST /collections/:collection_id/attachments.json
  def create
    logger.debug "attachments#create collection_id=#{params[:collection_id]}"

    # collection = Collection.find(params[:collection_id])

    # @attachment = Attachment.new({collection_id: collection.id})
    # logger.debug "params[:attachment].class = #{params[:attachment].class}"
    # logger.debug "params[:attachment] = #{params[:attachment]}"
    @attachment = Attachment.new(params[:attachment])
    @attachment.collection_id = params[:collection_id]
    @attachment.created_by = current_user.id

    # logger.debug "attachments#create before save, attachment=#{@attachment.to_jq_upload}"
    # respond_to do |format|
    #   if @attachment.save
    #     format.html { redirect_to @attachment, notice: 'Document was successfully created.' }
    #     format.json { render json: @attachment, status: :created, location: @attachment }
    #   else
    #     format.html { render action: "new" }
    #     format.json { render json: @attachment.errors, status: :unprocessable_entity }
    #   end
    # end

    # begin
    #   # @attachment.update_attributes
    #   @attachment.save!
    # rescue => error
    #   logger.debug "unable to save attachment: #{error}"
    # end

    # att = Attachment.find(@attachment)

    respond_to do |format|
      if @attachment.save
      # unless att.nil?
        format.html {
          render :json => [@attachment.to_jq_upload].to_json,
                 :content_type => 'text/html',
                 :layout => false
        }
        format.json { render json: {files: [@attachment.to_jq_upload]}, status: :created, location: @attachment }
      else
        format.html { render action: "new" }
        # format.json { render json: @attachment.errors, status: :unprocessable_entity }
        format.json { render json: {files: [@attachment.to_jq_error(@attachment.errors)]}, status: :created }
      end
    end
  end

  # PUT /collections/:collection_id/attachments/:id
  # PUT /collections/:collection_id/attachments/:id.json
  # def update
  #   @attachment = Document.find(params[:id])
  #
  #   respond_to do |format|
  #     if @attachment.update_attributes(params[:id])
  #       format.html { redirect_to @attachment, notice: 'Attachment was successfully updated.' }
  #       format.json { head :no_content }
  #     else
  #       format.html { render action: "edit" }
  #       format.json { render json: @attachment.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # DELETE /collections/:collection_id/attachments/:id
  # DELETE /collections/:collection_id/attachments/:id.json
  def destroy
    @attachment = Attachment.find(params[:id])
    attachment_dir = @attachment.file.store_dir

    logger.debug "attachments#destroy attachment_dir=#{attachment_dir}"

    @attachment.destroy
    FileUtils.remove_dir(attachment_dir, true)

    respond_to do |format|
      format.html { redirect_to attachments_url }
      format.json { head :no_content }
    end
  end

  # GET /attachments
  def download

  end

  def attachments_by_collection(collection_id)
    # collection = Collection.find_by_name(collection_id)
    Attachment.by_collection(collection_id)
  end
end

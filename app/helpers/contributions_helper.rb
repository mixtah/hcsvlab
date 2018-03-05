require Rails.root.join('lib/rdf-sesame/hcsvlab_server.rb')
require Rails.root.join('app/helpers/collections_helper.rb')
require 'zip'
require 'mimemagic'

module ContributionsHelper

  # include CollectionsHelper

  SESAME_CONFIG = YAML.load_file("#{Rails.root.to_s}/config/sesame.yml")[Rails.env] unless defined? SESAME_CONFIG

  # Load contribution's metadata, return json
  #
  #
  def self.load_contribution_metadata(contribution_name)
    logger.debug "load_contribution_metadata: start - contribution_name[#{contribution_name}]"

    contrib = Contribution.find_by_name(contribution_name)

    repo = MetadataHelper::get_repo_by_collection(contrib.collection.name)

    #   compose query
    query = %(
    PREFIX alveo: <http://alveo.edu.au/schema/>
    PREFIX dcterms: <http://purl.org/dc/terms/>

    SELECT ?property ?value
    WHERE {
    	?contrib a alveo:Contribution.
    	?contrib dcterms:identifier "#{contrib.id}".
			?contrib ?property ?value.
    }
    )

    # logger.debug "load_contribution_metadata: query[#{query}]"

    solutions = repo.sparql_query(query)

    if solutions.size != 0
      input = JSON.parse %(
      {
        "@id": "#{contrib.id}",
        "@type": "alveo:Contribution"
      })

      solutions.each do |solution|
        property = solution.to_h[:property].to_s
        value = solution.to_h[:value].to_s

        input[property] = value
      end
    end

    rlt = JSON::LD::API.compact(input, JsonLdHelper::default_context)

    logger.debug "load_contribution_metadata: rlt[#{rlt}]"

    return rlt
  end

  # To check whether user is the owner of specific contribution
  #
  # Only the contribution owner and admin can edit related contribution
  #
  def self.is_owner?(user, contribution)
    logger.debug "is_owner: start - user[#{user}], contribution[#{contribution}]"
    rlt = false

    if contribution.nil?
      # contribution is nil, no one is the owner
    else
      if user.nil?
        #   user is nil, nil user is not the owner
      else
        if contribution.owner.id == user.id || user.is_superuser?
          rlt = true
        end
      end
    end

    logger.debug "is_owner: end - rlt[#{rlt}]"

    rlt
  end


  #
  # Extract entry name (file name) from zip file. No extraction, just read from central directory.
  #
  # Return - array of hash, or string if failed
  #
  # rlt = [{
  #   :name => file base name,
  #   :size => file size
  # }]
  #
  #
  def self.entry_names_from_zip(zip_file)
    logger.debug "entry_names_from_zip: start - zip_file[#{zip_file}]"

    rlt = []

    begin
      Zip::File.open(zip_file) do |file|
        # Handle entries one by one
        file.each do |entry|
          if entry.ftype == :file
            rlt << {
              :name => File.basename(entry.name),
              :size => entry.size
            }
          end
        end
      end
    rescue Zip::Error => e
      rlt = e.message
    end

    logger.debug "entry_names_from_zip: end - rlt[#{rlt}]"

    return rlt
  end

  #
  # Validate contribution file.
  #
  # According to file name, retrieve associated document and item info. If input file
  # has the same file name as document file name (except the file ext), it is validated
  #
  # e.g., input file [abc.txt], if document file [abc.wav] exists in the same collection, this input file is validated.

  # However, if input file has the same name as document file, it is invalidated.
  #
  # Return hash.
  #
  # {
  #   :file => input file (basename),
  #   :item_handle => item.handle (e.g., mava:s203, nil if not found),
  #   :document_file_name => [document.file_name] (array of string, nil if not found),
  #   :dest_file => destination file name (basename), nil if validate failed
  #   :message => nil (no news is good news, otherwise error message)
  # }
  #
  def self.validate_contribution_file(contribution_id, file)
    logger.debug "validate_contribution_file: start - contribution_id[#{contribution_id}], file[#{file}]"

    contrib = Contribution.find_by_id(contribution_id)

    rlt = {
      :file => file,
      :item_handle => nil,
      :document_file_name => [],
      :dest_file => file,
      :message => nil
    }

    # document file: abc.txt
    # pattern is "abc", all files start with "abc" would be retrieved
    pattern = File.basename(file, ".*")

    sql = %(
    SELECT
      i.handle as item_handle, d.file_name as document_file_name, cm.contribution_id as contribution_id
    FROM
      items i, documents d
    LEFT OUTER JOIN contribution_mappings cm
      ON d.id = cm.document_id
    WHERE
      i.collection_id = #{contrib.collection_id}
      AND d.item_id = i.id
      AND d.file_name like '#{pattern}%'
    )

    result = ActiveRecord::Base.connection.execute(sql)
    if result.count == 0
      rlt[:message] = "can't find existing document associated with [#{file}]"
      rlt[:dest_file] = nil
    end

    result.each do |row|
      rlt[:item_handle] = row["item_handle"]
      rlt[:document_file_name] << row["document_file_name"]

      if (file == row["document_file_name"])
        # input file has the same name as document file, duplicated warning
        # need to further check duplicated file is from same contribution or not

        # if duplicated file is from same contribution, overwrite
        # otherwise (from collection or different contribution) need to rename

        name_result = next_available_name(
          contribution_id,
          file,
          result.map {|e| {
            :name => e["document_file_name"],
            :contrib_id => e["contribution_id"]}}
        )

        rlt[:message] = "duplicated document found[#{file}]. "
        rlt[:dest_file] = name_result[:file_name]

        if name_result[:mode] == "rename"
          rlt[:message] += "New file would be renamed as '#{name_result[:file_name]}'."
        else
          if name_result[:mode] == "overwrite"
            rlt[:message] += "Existing file would be overwritten as '#{name_result[:file_name]}'."
          end
        end
      end
    end

    logger.debug "validate_contribution_file: end - rlt[#{rlt}]"

    return rlt
  end

  #
  # Import document into contribution.
  #
  # Return: result (string)
  #
  # - success: xx document(s) imported.
  # - failed: failed message
  #
  def self.import(contribution)
    logger.debug "import: start - contribution[#{contribution}]"

    rlt = "import failed - "
    # run preview again to ensure zip file ok
    contrib_doc = preview_import(contribution)

    # ensure no failed doc
    failed_doc = []
    if contrib_doc.is_a?(Array)
      contrib_doc.each do |d|
        if !d[:message].nil? && d[:dest_file].nil?
          failed_doc << d[:message]
        end
      end
    else
      #   sth error happened
      rlt += contrib_doc.to_s
      logger.error "import: rlt[#{rlt}]"

      return rlt
    end

    if failed_doc.size > 0
      #   failed doc found
      rlt += failed_doc.join("; ")
    else
      # unzip file
      zip_file = contribution_import_zip_file(contribution)
      unzip_dir = File.join(File.dirname(zip_file), File.basename(zip_file, ".zip"))

      extracted_file = unzip(zip_file, unzip_dir)
      if extracted_file.is_a? String
        #   sth wrong happened
        logger.error "import: return from unzip: #{extracted_file}"
        rlt = extracted_file

        return rlt
      end

      contrib_doc.each do |doc|
        begin
          contrib_id = contribution.id
          item_handle = %(#{contribution.collection.name}:#{doc[:item]})
          # find full path thru :name mapping
          extracted_filepath = (extracted_file.select {|e| e[:name] == doc[:name]}.first)[:dest_name]

          # move(rename): from extracted file to destination file
          doc_file = File.join(File.dirname(extracted_filepath), doc[:dest_file])
          if extracted_filepath != doc_file
            FileUtils.mv(extracted_filepath, doc_file)
          end

          add_document_to_contribution(contrib_id, item_handle, doc_file)
            # logger.info "import: contribution_id[#{contrib_id}], item_handle[#{item_handle}], doc_file[#{doc_file}]"

        rescue Exception => e
          logger.error "import: exception happened during add document to contribution [#{e.message}]"

          rlt += "#{e.message}"

          return rlt
        end
      end

      # finally, get there
      # clean up
      FileUtils.rm_f(zip_file)
      FileUtils.rm_rf(unzip_dir)

      rlt = "OK! #{contrib_doc.size} document(s) imported."
    end

    logger.debug "import: end - rlt[#{rlt}]"

    return rlt
  end

  #
  # Unzip contribution's import zip file to specific dir.
  #
  # Return:
  #
  # - success: array of hash
  #   rlt = [
  #     {
  #       :name => file name (basename),
  #       :dest_name => extracted file name (full path)
  #     }
  #   ]
  # - failed: string (message)
  def self.unzip(zip_file, unzip_dir)
    logger.debug "unzip: start - zip_file[#{zip_file}], unzip_dir[#{unzip_dir}]"
    rlt = []

    # init unzip_dir
    FileUtils.mkdir_p(unzip_dir)

    begin
      Zip::File.open(zip_file) do |zf|
        # Handle entries one by one
        zf.each do |entry|
          # init dest file
          dest_name = File.join(unzip_dir, entry.name)
          FileUtils.mkdir_p(File.dirname(dest_name))
          FileUtils.rm_f(dest_name)

          entry.extract(dest_name)

          rlt << {
            :name => File.basename(entry.name),
            :dest_name => dest_name
          }
        end
      end
    rescue Zip::Error => e
      logger.error "unzip: #{e.message}"
      rlt = e.message
    end

    logger.debug "unzip: end - rlt[#{rlt}]"

    return rlt
  end

  #
  # Add document to contribution.
  #
  # - Document (file) already exists.
  # - file already validated
  #
  #
  def self.add_document_to_contribution(contribution_id, item_handle, doc_file)
    logger.debug "add_document_to_contribution: start - contribution_id[#{contribution_id}], item_handle[#{item_handle}], doc_file[#{doc_file}]"

    # compose file attr
    contribution = Contribution.find_by_id(contribution_id)

    # /data/contrib/:collection_name/:contrib_id/:filename
    contrib_dir = contribution_dir(contribution)

    # # get available file name
    # name_result = next_available_name(contribution_id)

    file_path = File.join(contrib_dir, File.basename(doc_file))
    logger.debug "add_document_to_contribution: processing [#{file_path}]"

    # copy extracted document file from temp to corpus dir
    logger.debug("add_document_to_contribution: copying document file from #{doc_file} to #{file_path}")
    FileUtils.cp(doc_file, file_path)

    contrib_metadata = JSON.parse(%(
    {
      "alveo:Contribution": "#{contribution_id}"
    }))

    doc_json = JsonLdHelper.construct_document_json_ld(
      contribution.collection,
      Item.find_by_handle(item_handle),
      "eng - English",
      file_path,
      contrib_metadata)

    CollectionsHelper.add_document_core(contribution.collection, Item.find_by_handle(item_handle), doc_json, file_path)

  end

  # extract document type from file basename
  #
  # Use gem "mimemagic" to handle this (at this version only by extension).
  #
  # File's document type is media type. e.g.,
  #
  # test.mp4: mediatype[video], subtype[mp4]
  # test.txt: mediatype[text], subtype[plain]
  #
  def self.extract_doc_type(file)
    rlt = MimeMagic.by_path(file)
    if rlt.nil?
      rlt = "application"
    else
      rlt = rlt.mediatype
    end

    return rlt
  end

  #
  # Return array of hash:
  #
  # {
  #   :mp_id => mapping id
  #   :item_name => name of associated item
  #   :document_file_name => file name of associated document
  #   :document_doc_type => file type of associated document
  # }
  def self.load_contribution_mapping(contribution)
    mappings = ContributionMapping.where(:contribution_id => contribution.id)

    rlt = []

    mappings.each do |mp|
      doc = Document.find_by_id(mp.document_id)
      hash = {
        :mp_id => mp.id,
        :item_name => Item.find_by_id(mp.item_id).get_name,
        :document_file_name => doc.file_name,
        :document_doc_type => doc.doc_type
      }

      rlt << hash
    end

    logger.debug "load_contribution_mapping: end - rlt[#{rlt}]"

    return rlt
  end

  #
  # Load import preview according to contribution.
  #
  # 0. locate zip file according to contribution (contrib dir)
  # 1. extract entry info (zipped file info, but not extract whole zip)
  # 2. check file one by one
  # 3. return all files' preview info (can import or not, reason)
  #
  # Return: array of hash, or string is error
  #
  # rlt = [
  #   {
  #     :name => file base name,
  #     :size => file size,
  #     :type => file type,
  #     :item => associated item name,
  #     :document => associated document name,
  #     :dest_file => destination file base name, nil if validate failed
  #     :message => error message (no news is good news, nil is good)
  #   }
  # ]
  #
  def self.preview_import(contribution)
    logger.debug "preview_import: start - contribution[#{contribution.name}]"

    rlt = []

    # locate zip file
    zip = contribution_import_zip_file(contribution)

    doc_files = entry_names_from_zip(zip)

    if doc_files.is_a? String
      rlt = doc_files
      logger.error "preview_import: rlt[#{rlt}]"
      return rlt
    end

    doc_files.each do |f|
      #   check file one by one
      vld_rlt = validate_contribution_file(contribution.id, f[:name])

      rlt << {
        :name => f[:name],
        :size => f[:size],
        :type => extract_doc_type(f[:name]),
        :item => (vld_rlt[:item_handle].split(":").last unless vld_rlt[:item_handle].nil?),
        :document => (vld_rlt[:document_file_name] unless vld_rlt[:document_file_name].nil?),
        :dest_file => vld_rlt[:dest_file],
        :message => vld_rlt[:message]
      }

    end

    logger.debug "preview_import: end - rlt[#{rlt}]"

    rlt
  end

  #
  # Find next available file name (if duplicated name exits) for contribution import.
  #
  # process rule:
  #
  # - overwrite
  #   - if collection-document, can't overwrite, need to rename (rule?)
  #   - if contribution-document, just overwrite (easiest to implement)
  #
  # - rename
  # - auto suffix (goal: make it easy to identify all of these files as being associated with each other)
  # - e.g., user upload file.txt via contrib x (id: x)
  # - if collection-document file.txt exists
  # - rename to file-cx.txt (suffix "-cx", means from contribution x). if file-cx.txt already exits, refer to following rules.
  #   - if contribution-document file.txt exists (from same contribution)
  # - overwrite file.txt
  # - if contribution-document file.txt exists (from different contribution, but two contributions associated to same collection)
  # - rename to file-cx.txt
  #
  # Return: string hash
  #
  # {
  #   :mode => "overwrite" / "rename",
  #   :file_name => available file name
  # }
  #
  def self.next_available_name(contrib_id, src_file, existing_files)
    logger.debug "next_available_name: start - contrib_id[#{contrib_id}], src_file[#{src_file}], existing_files[#{existing_files}]"

    rlt = {:mode => 'rename', :file_name => "#{src_file}"}

    existing_files.each do |f|
      if f[:name] == src_file
        #   duplicated file found
        #   check contribution
        if f[:contrib_id].to_s == contrib_id.to_s
          #   same contribution with src file, overwrite mode
          rlt[:mode] = "overwrite"
          logger.debug "next_available_name: rlt[#{rlt}]"
          break
        else
          #   collection document or different contribution, rename mode
          #   abc.txt => abc-cx.txt (x is contribution id)
          dest_file = File.basename(src_file, File.extname(src_file)) + "-c#{contrib_id}" + File.extname(src_file)

          # further check dest_file available
          rlt = next_available_name(contrib_id, dest_file, existing_files)
        end
      end
    end

    logger.debug "next_available_name: end - rlt[#{rlt}]"

    return rlt

  end

  #
  # zip file name:
  #
  # APP_CONFIG["contrib_dir"] (config/hcsvlab-web_config.yml: contrib_dir)
  #
  def self.contribution_import_zip_file(contribution)
    rlt = nil

    if !contribution.nil?
      rlt = File.join(APP_CONFIG["contrib_dir"], contribution.collection.name, "import_#{contribution.id.to_s}.zip")
    end

    rlt
  end

  #
  # directory name:
  #
  # APP_CONFIG["contrib_dir"] (config/hcsvlab-web_config.yml: contrib_dir)
  #
  def self.contribution_dir(contribution)
    rlt = nil

    if !contribution.nil?
      begin
        rlt = File.join(APP_CONFIG["contrib_dir"], contribution.collection.name, contribution.id.to_s)
      rescue Exception => e
        logger.error "contribution_dir: #{e.message}"
      end
    end

    return rlt
  end


  #
  # Call CollectionHelper.delete_doc_core to delete document
  #
  # One contribution associates to 1 collection, multiple items and multiple documents.
  #
  # Return hash:
  #
  # {
  #   message: failure reason, nil if success (no news is good news)
  #   document_count: deleted document count (nil if delete failure)
  # }
  #
  def self.delete_contribution(contribution)
    logger.debug "delete_contribution: start - contribution[#{contribution}]"
    rlt = {message: nil, document_count: nil}

    collection = contribution.collection
    # contrib_dir = contribution_dir(contribution)

    begin
      result = ContributionMapping.where(:contribution_id => contribution.id)
      # delete all related document one-by-one
      result.each do |row|
        item = Item.find_by_id(row.item_id)
        document = Document.find_by_id(row.document_id)

        CollectionsHelper.delete_document_core(collection, item, document)
      end

      #   delete related contribution mapping
      ContributionMapping.delete_all(contribution_id: contribution.id)

      # delete contribution
      contribution.destroy

      rlt[:document_count] = result.count
    rescue Exception => e
      logger.error "delete_contribution: #{e.inspect}"
      rlt[:message] = e.message
    end

    logger.debug "delete_contribution: end - rlt[#{rlt}]"

    rlt
  end

  #
  # Export contribution as zip file. Compress all files in contrib_dir as {id}.zip
  #
  # Contribution document files only include those within contribution_mappings.
  #
  # Return zip file path if success , otherwise exception throws
  #
  def self.export_as_zip(contribution)
    logger.debug "export_as_zip: start - contribution[#{contribution}]"

    rlt = nil

    begin
      # collect contribution document file path
      file_path = []
      cm_list = ContributionMapping.where(contribution_id: contribution.id)
      cm_list.each do |cm|
        file_path << cm.document.file_path
      end

      # generate zip path
      zip_path = File.join(APP_CONFIG['download_tmp_dir'], "contrib_export_#{contribution.id}_#{Time.now.getutc.to_i.to_s}.zip")

      # zip it
      ZipBuilder.build_simple_zip_from_files(zip_path, file_path)

      rlt = zip_path
    rescue Exception => e
      logger.error "export_as_zip: #{e.message}"
      raise Exception.new(e.message)
    end

    logger.debug "export_as_zip: end - rlt[#{rlt}]"

    return rlt
  end

end


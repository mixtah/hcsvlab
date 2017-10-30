require Rails.root.join('lib/rdf-sesame/hcsvlab_server.rb')
require Rails.root.join('app/helpers/collections_helper.rb')
require 'zip'

module ContributionsHelper

  # include CollectionsHelper

  SESAME_CONFIG = YAML.load_file("#{Rails.root.to_s}/config/sesame.yml")[Rails.env] unless defined? SESAME_CONFIG

  # Load contribution's metadata, return json
  #
  #
  def self::load_contribution_metadata(contribution_name)
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

    logger.debug "load_contribution_metadata: query[#{query}]"

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

  def create_contribution()

  end

  # To check whether user is the owner of specific contribution
  #
  # Only the contribution owner and admin can edit related contribution
  #
  def self::is_owner(user, contribution)
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
  # Return - string array of file basename
  #
  def self::entry_names_from_zip(zip_file)
    logger.debug "entry_names_from_zip: start - zip_file[#{zip_file}]"

    rlt = []

    Zip::File.open(zip_file) do |file|
      # Handle entries one by one
      file.each do |entry|
        rlt << File.basename(entry.name)
      end
    end

    logger.debug "entry_names_from_zip: end - rlt[#{rlt}]"
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
  #   :document_file_name => document.file_name (e.g., s1_48k.wav, nil if not found),
  #   :error => nil (no news is good news)
  # }
  #
  def self::validate_contribution_file(collection_id, file)
    logger.debug "validate_contribution_file: start - collection_id[#{collection_id}], file[#{file}]"

    error_msg = "can't find existing document associated with [#{file.original_filename}]"
    rlt = {
      :error => error_msg
    }

    # document files: abc.wav, abc_1.wav
    # if pattern is only "abc", both abc.wav and abc_1.wav would be retrieved.
    # so pattern should include the dot
    uplaoded_file_name = File.basename(file.original_filename)
    pattern = File.basename(uplaoded_file_name, ".*") + "."

    sql = %(
    SELECT
      i.handle as item_handle, d.file_name as document_file_name
    FROM
      items i, documents d
    WHERE
      i.collection_id = #{collection_id}
      AND d.item_id = i.id
      AND d.file_name like '#{pattern}%'
    )

    logger.debug "validate_contribution_file: sql[#{sql}]"

    result = ActiveRecord::Base.connection.execute(sql)
    result.each do |row|
      error = nil

      if (uplaoded_file_name == row["document_file_name"])
      #   input file has the same name as document file, invalidated
        error = "duplicated document file [#{uplaoded_file_name}]"
      end

      rlt = {
        :file => file,
        :item_handle => row["item_handle"],
        :document_file_name => row["document_file_name"],
        :error => error
      }
    end

    logger.debug "validate_contribution_file: end - rlt[#{rlt}]"

    return rlt
  end

  #
  # Add document to contribution.
  #
  # - Document (file) already uploaded.
  # - file already validated
  #
  #
  def self::add_document_to_contribution(contribution_id, item_handle, uploaded_file)
    logger.debug "add_document_to_contribution: start - contribution_id[#{contribution_id}], item_handle[#{item_handle}], uploaded_file[#{uploaded_file.to_s}]"
    # call CollectionsController.add_document_core to add to item

    # compose file attr
    contribution = Contribution.find_by_id(contribution_id)

    # /data/contrib/:collection_name/:contrib_id/:filename
    contrib_dir = File.join(APP_CONFIG["contrib_dir"], contribution.collection.name, contribution_id)
    file_path = File.join(contrib_dir, File.basename(uploaded_file.original_filename))

    doc_type = self::extract_doc_type(File.basename(file_path))

    # copy uploaded document file from temp to corpus dir
    logger.debug("add_document_to_contribution: copying uploaded document file from #{uploaded_file.tempfile} to #{file_path}")
    FileUtils.cp uploaded_file.tempfile, file_path

    # construct document Json-ld
    doc_uri = Item.find_by_handle(item_handle).uri + "/document/#{File.basename(file_path)}"

    doc_json = JSON.parse(%(
    {
      "@context": {
        "dcterms": "http://purl.org/dc/terms/",
        "foaf": "http://xmlns.com/foaf/0.1/",
        "alveo": "http://alveo.edu.au/schema/"
      },
      "@id": "#{doc_uri}",
      "@type": "foaf:Document",
      "alveo:Contribution": "#{contribution_id}",
      "dcterms:source": "#{file_path}",
      "dcterms:identifier": "#{File.basename(file_path)}",
      "dcterms:type": "#{doc_type}",
      "dcterms:title": "#{File.basename(file_path)}##{doc_type}"
    }))

    CollectionsHelper.add_document_core(contribution.collection, Item.find_by_handle(item_handle), doc_json, File.basename(file_path))

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

  def self::extract_doc_type(file)
    rlt = MimeMagic.by_path(file).mediatype
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
  def self::load_contribution_mapping(contribution)
    mappings = ContributionMapping.where(:contribution_id => contribution.id)

    rlt = []

    mappings.each do |mp|
      hash = {
        :mp_id => mp.id,
        :item_name => Item.find_by_id(mp.item_id).get_name,
        :document_file_name => Document.find_by_id(mp.document_id).file_name,
        :document_doc_type => Document.find_by_id(mp.document_id).doc_type
      }

      rlt << hash
    end

    logger.debug "load_contribution_mapping: end - rlt[#{rlt}]"

    return rlt
  end

end


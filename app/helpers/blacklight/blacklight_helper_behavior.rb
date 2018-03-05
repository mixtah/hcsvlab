# -*- encoding : utf-8 -*-
# -*- coding: utf-8 -*-
require 'open-uri'

# Methods added to this helper will be available to all templates in the hosting application
#
module Blacklight::BlacklightHelperBehavior
  include HashAsHiddenFieldsHelper
  include RenderConstraintsHelper
  include HtmlHeadHelper
  include FacetsHelper

  SESAME_CONFIG = YAML.load_file("#{Rails.root.to_s}/config/sesame.yml")[Rails.env] unless const_defined?(:SESAME_CONFIG)

  def application_name
    return Rails.application.config.application_name if Rails.application.config.respond_to? :application_name

    t('blacklight.application_name')
  end

  # Provide the full, absolute url for an image
  def asset_url(*args)
    "#{request.protocol}#{request.host_with_port}#{asset_path(*args)}"
  end

  # Create <link rel="alternate"> links from a documents dynamically
  # provided export formats. Currently not used by standard BL layouts,
  # but available for your custom layouts to provide link rel alternates.
  #
  # Returns empty string if no links available.
  #
  # :unique => true, will ensure only one link is output for every
  # content type, as required eg in atom. Which one 'wins' is arbitrary.
  # :exclude => array of format shortnames, formats to not include at all.
  def render_link_rel_alternates(document=@document, options = {})
    options = {:unique => false, :exclude => []}.merge(options)

    return nil if document.nil?

    seen = Set.new

    html = ""
    document.export_formats.each_pair do |format, spec|
      unless (options[:exclude].include?(format) ||
        (options[:unique] && seen.include?(spec[:content_type]))
      )
        html << tag(:link, {:rel => "alternate", :title => format, :type => spec[:content_type], :href => polymorphic_url(document, :format => format)}) << "\n"

        seen.add(spec[:content_type]) if options[:unique]
      end
    end
    return html.html_safe
  end

  def render_opensearch_response_metadata
    render :partial => 'catalog/opensearch_response_metadata'
  end

  def render_body_class
    extra_body_classes.join " "
  end

  # collection of items to be rendered in the @sidebar
  def sidebar_items
    @sidebar_items ||= []
  end

  # collection of items to be rendered in the @topbar
  def topbar_items
    @topbar_items ||= []
  end

  def render_search_bar
    render :partial => 'catalog/search_form'
  end

  def search_action_url
    catalog_index_url
  end

  def extra_body_classes
    @extra_body_classes ||= ['blacklight-' + controller.controller_name, 'blacklight-' + [controller.controller_name, controller.action_name].join('-')]
  end

  def render_document_list_partial options={}
    render :partial => 'catalog/document_list'
  end

  # Save function area for search results 'index' view, normally
  # renders next to title.
  def render_index_doc_actions(document, options={})
    wrapping_class = options.delete(:wrapping_class) || "documentFunctions"

    content = []
    content << render(:partial => 'catalog/bookmark_control', :locals => {:document => document}.merge(options)) if has_user_authentication_provider? and current_or_guest_user

    content_tag("div", content.join("\n").html_safe, :class => wrapping_class)
  end

  # Save function area for item detail 'show' view, normally
  # renders next to title. By default includes 'Bookmarks'
  def render_show_doc_actions(document=@document, options={})
    wrapping_class = options.delete(:documentFunctions) || "documentFunctions"
    content = []
    content << render(:partial => 'catalog/bookmark_control', :locals => {:document => document}.merge(options)) if has_user_authentication_provider? and current_or_guest_user

    content_tag("div", content.join("\n").html_safe, :class => "documentFunctions")
  end

  ##
  # Index fields to display for a type of document
  def index_fields document=nil
    blacklight_config.index_fields
  end

  def should_render_index_field? document, solr_field
    document.has?(solr_field.field) ||
      (document.has_highlight_field? solr_field.field if solr_field.highlight)
  end

  ##
  # Field keys for the index fields
  # @deprecated
  def index_field_names document=nil
    index_fields(document).keys
  end

  ##
  # Labels for the index fields
  # @deprecated
  def index_field_labels document=nil
    # XXX DEPRECATED
    Hash[*index_fields(document).map {|key, field| [key, field.label]}.flatten]
  end

  def spell_check_max
    blacklight_config.spell_max
  end

  ##
  # Render the index field label for a document
  #
  # @overload render_index_field_label(options)
  #   Use the default, document-agnostic configuration
  #   @param [Hash] opts
  #   @options opts [String] :field
  # @overload render_index_field_label(document, options)
  #   Allow an extention point where information in the document
  #   may drive the value of the field
  #   @param [SolrDocument] doc
  #   @param [Hash] opts
  #   @options opts [String] :field    
  def render_index_field_label *args
    options = args.extract_options!
    document = args.first

    field = options[:field]
    html_escape index_fields(document)[field].label
  end

  ##
  # Render the index field label for a document
  #
  # @overload render_index_field_value(options)
  #   Use the default, document-agnostic configuration
  #   @param [Hash] opts
  #   @options opts [String] :field
  #   @options opts [String] :value
  #   @options opts [String] :document
  # @overload render_index_field_value(document, options)
  #   Allow an extention point where information in the document
  #   may drive the value of the field
  #   @param [SolrDocument] doc
  #   @param [Hash] opts
  #   @options opts [String] :field 
  #   @options opts [String] :value
  # @overload render_index_field_value(document, field, options)
  #   Allow an extention point where information in the document
  #   may drive the value of the field
  #   @param [SolrDocument] doc
  #   @param [String] field
  #   @param [Hash] opts
  #   @options opts [String] :value
  def render_index_field_value *args
    options = args.extract_options!
    document = args.shift || options[:document]

    field = args.shift || options[:field]
    value = options[:value]


    field_config = index_fields(document)[field]

    value ||= case
                when value
                  value
                when (field_config and field_config.helper_method)
                  send(field_config.helper_method, options.merge(:document => document, :field => field))
                when (field_config and field_config.highlight)
                  document.highlight_field(field_config.field).map {|x| x.html_safe}
                else
                  document.get(field, :sep => nil) if field
              end

    render_field_value value
  end

  # Used in the show view for displaying the main solr document heading
  def document_heading document=nil
    document ||= @document
    begin
      document[:handle]
    rescue
      document[blacklight_config.show.heading] || document.id
    end
  end

  def main_link_label(document)
    document[:handle]
  end

  ##
  # Render the document "heading" (title) in a content tag
  # @overload render_document_heading(tag)
  # @overload render_document_heading(document, options)
  #   @params [SolrDocument] document
  #   @params [Hash] options
  #   @options options [Symbol] :tag
  def render_document_heading(*args)
    options = args.extract_options!
    if args.first.is_a? SolrDocument
      document = args.shift
      tag = options[:tag]
    else
      document = nil
      tag = args.first || options[:tag]
    end

    tag ||= :h4

    content_tag(tag, render_field_value(document_heading(document)))
  end

  # Used in the show view for setting the main html document title
  def document_show_html_title document=nil
    document ||= @document
    render_field_value(document[blacklight_config.show.html_title])
  end

  # Used in citation view for displaying the title
  def citation_title(document)
    document[blacklight_config.show.html_title]
  end

  # Used in the document_list partial (search view) for building a select element
  def sort_fields
    blacklight_config.sort_fields.map {|key, x| [x.label, x.key]}
  end

  # Used in the document list partial (search view) for creating a link to the document show action
  def document_show_link_field document=nil
    blacklight_config.index.show_link.to_sym
  end

  # Used in the search form partial for building a select tag
  def search_fields
    search_field_options_for_select
  end

  # used in the catalog/_show/_default partial
  def document_show_fields document=nil
    blacklight_config.show_fields
  end

  # used in the catalog/_show/_default partial
  # @deprecated
  def document_show_field_labels document=nil
    # XXX DEPRECATED
    Hash[*document_show_fields(document).map {|key, field| [key, field.label]}.flatten]
  end

  ##
  # Render the show field label for a document
  #
  # @overload render_document_show_field_label(options)
  #   Use the default, document-agnostic configuration
  #   @param [Hash] opts
  #   @options opts [String] :field
  # @overload render_document_show_field_label(document, options)
  #   Allow an extention point where information in the document
  #   may drive the value of the field
  #   @param [SolrDocument] doc
  #   @param [Hash] opts
  #   @options opts [String] :field   
  def render_document_show_field_label *args
    options = args.extract_options!
    document = args.first

    field = options[:field]

    html_escape document_show_fields(document)[field].label
  end

  ##
  # Render the index field label for a document
  #
  # @overload render_document_show_field_value(options)
  #   Use the default, document-agnostic configuration
  #   @param [Hash] opts
  #   @options opts [String] :field
  #   @options opts [String] :value
  #   @options opts [String] :document
  # @overload render_document_show_field_value(document, options)
  #   Allow an extention point where information in the document
  #   may drive the value of the field
  #   @param [SolrDocument] doc
  #   @param [Hash] opts
  #   @options opts [String] :field 
  #   @options opts [String] :value
  # @overload render_document_show_field_value(document, field, options)
  #   Allow an extention point where information in the document
  #   may drive the value of the field
  #   @param [SolrDocument] doc
  #   @param [String] field
  #   @param [Hash] opts
  #   @options opts [String] :value
  def render_document_show_field_value *args

    options = args.extract_options!
    document = args.shift || options[:document]

    field = args.shift || options[:field]
    value = options[:value]


    field_config = document_show_fields(document)[field]

    value ||= case
                when value
                  value
                when (field_config and field_config.helper_method)
                  send(field_config.helper_method, options.merge(:document => document, :field => field))
                when (field_config and field_config.highlight)
                  document.highlight_field(field_config.field).map {|x| x.html_safe}
                else
                  document.get(field, :sep => nil) if field
              end

    render_field_value value
  end

  def should_render_show_field? document, solr_field
    document.has?(solr_field.field) ||
      (document.has_highlight_field? solr_field.field if solr_field.highlight)
  end

  def render_field_value value=nil
    value = [value] unless value.is_a? Array
    value = value.collect {|x| x.respond_to?(:force_encoding) ? x.force_encoding("UTF-8") : x}
    return value.map {|v| html_escape v}.join(field_value_separator).html_safe
  end

  def field_value_separator
    ', '
  end

  def document_index_view_type
    if blacklight_config.document_index_view_types.include? params[:view]
      params[:view]
    else
      blacklight_config.document_index_view_types.first
    end
  end

  def render_document_index documents = nil, locals = {}, extraRenderParams = {}
    documents ||= @document_list

    document_index_path_templates.each do |str|
      # XXX rather than handling this logic through exceptions, maybe there's a Rails internals method
      # for determining if a partial template exists..
      begin
        return render(:partial => (str % {:index_view_type => document_index_view_type}), :locals => {:documents => documents, :extraRenderParams => extraRenderParams})
      rescue ActionView::MissingTemplate
        nil
      end
    end

    return ""
  end

  # a list of document partial templates to try to render for #render_document_index
  def document_index_path_templates
    # first, the legacy template names for backwards compatbility
    # followed by the new, inheritable style
    # finally, a controller-specific path for non-catalog subclasses
    @document_index_path_templates ||= ["document_%{index_view_type}", "catalog/document_%{index_view_type}", "catalog/document_list"]
  end

  # Return a normalized partial name that can be used to contruct view partial path
  def document_partial_name(document)
    # .to_s is necessary otherwise the default return value is not always a string
    # using "_" as sep. to more closely follow the views file naming conventions
    # parameterize uses "-" as the default sep. which throws errors
    display_type = document[blacklight_config.show.display_type]

    return 'default' unless display_type
    display_type = display_type.join(" ") if display_type.respond_to?(:join)

    "#{display_type.gsub("-", " ")}".parameterize("_").to_s
  end

  # given a doc and action_name, this method attempts to render a partial template
  # based on the value of doc[:format]
  # if this value is blank (nil/empty) the "default" is used
  # if the partial is not found, the "default" partial is rendered instead
  def render_document_partial(doc, action_name, locals = {})
    format = document_partial_name(doc)

    document_partial_path_templates.each do |str|
      # XXX rather than handling this logic through exceptions, maybe there's a Rails internals method
      # for determining if a partial template exists..
      begin
        return render :partial => (str % {:action_name => action_name, :format => format, :index_view_type => document_index_view_type}), :locals => locals.merge({:document => doc})
      rescue ActionView::MissingTemplate
        nil
      end
    end

    return ''
  end

  # a list of document partial templates to try to render for #render_document_partial
  def document_partial_path_templates
    # first, the legacy template names for backwards compatbility
    # followed by the new, inheritable style
    # finally, a controller-specific path for non-catalog subclasses
    @partial_path_templates ||= ["%{action_name}_%{index_view_type}_%{format}", "%{action_name}_%{index_view_type}_default", "%{action_name}_%{format}", "%{action_name}_default", "catalog/%{action_name}_%{format}", "catalog/_%{action_name}_partials/%{format}", "catalog/_%{action_name}_partials/default"]
  end


  # Search History and Saved Searches display
  def link_to_previous_search(params)
    link_to(raw(render_search_to_s(params) + render_search_to_s_metadata(params)), catalog_index_path(params)).html_safe
  end

  def render_search_to_s_metadata(params)
    return "".html_safe if params[:metadata].blank?

    label = ' Metadata'

    render_search_to_s_element(label, params[:metadata])

  end

  #
  # shortcut for built-in Rails helper, "number_with_delimiter"
  #
  def format_num(num)
    ; number_with_delimiter(num)
  end

  #
  # link based helpers ->
  #

  # create link to query (e.g. spelling suggestion)
  def link_to_query(query)
    p = params.dup
    p.delete :page
    p.delete :action
    p[:q]=query
    link_url = catalog_index_path(p)
    link_to(query, link_url)
  end

  def render_document_index_label doc, opts
    label = nil
    label ||= doc.get(opts[:label], :sep => nil) if opts[:label].instance_of? Symbol
    label ||= opts[:label].call(doc, opts) if opts[:label].instance_of? Proc
    label ||= opts[:label] if opts[:label].is_a? String
    label ||= doc.id
    render_field_value label
  end

  # link_to_document(doc, :label=>'VIEW', :counter => 3)
  # Use the catalog_path RESTful route to create a link to the show page for a specific item.
  # catalog_path accepts a HashWithIndifferentAccess object. The solr query params are stored in the session,
  # so we only need the +counter+ param here. We also need to know if we are viewing to document as part of search results.
  def link_to_document(doc, opts={:label => nil, :counter => nil, :results_view => true})
    opts[:label] ||= blacklight_config.index.show_link.to_sym
    label = render_document_index_label doc, opts
    link_to label, doc, {:'data-counter' => opts[:counter]}.merge(opts.reject {|k, v| [:label, :counter, :results_view].include? k})
  end

  # link_literal_to_document(doc, :label=>'VIEW', :counter => 3)
  # Use the catalog_path RESTful route to create a link to the show page for a specific item.
  # catalog_path accepts a HashWithIndifferentAccess object. The solr query params are stored in the session,
  # so we only need the +counter+ param here. We also need to know if we are viewing to document as part of search results.
  def link_literal_to_document(doc, label, opts={:counter => nil, :results_view => true})
    collectionName = Array(doc[MetadataHelper.short_form(MetadataHelper::COLLECTION)]).first
    itemIdentifier = doc[:handle].split(':').last

    logger.debug "link_literal_to_document: opts[#{opts}], collectionName[#{collectionName}], itemIdentifier[#{itemIdentifier}]"

    if !opts[:itemViewList].nil?
      link_to label, solr_document_path(collectionName, itemIdentifier, :il => opts[:itemViewList])
    else
      link_to label, catalog_url(collectionName, itemIdentifier), {:'data-counter' => opts[:counter]}.merge(opts.reject {|k, v| [:label, :counter, :results_view].include? k})
    end
  end

  # link_back_to_catalog(:label=>'Back to Search')
  # Create a link back to the index screen, keeping the user's facet, query and paging choices intact by using session.
  def link_back_to_catalog(opts={:label => nil})
    query_params = session[:search] ? session[:search].dup : {}
    query_params.delete :counter
    query_params.delete :total
    link_url = url_for(query_params)
    if link_url =~ /bookmarks/
      opts[:label] ||= t('blacklight.back_to_bookmarks')
    end

    opts[:label] ||= t('blacklight.back_to_search')

    link_to opts[:label], link_url, :class => "btn"
  end

  def get_type_format(document, is_cooee)
    type = nil
    if is_cooee
      field = MetadataHelper::TYPE.to_s + "_tesim"
      if document.has_key?(field)
        document[field].each {|t| type = t unless t == "Original" or t == "Raw"}
      else
        field = "DC_type_facet"
        if document.has_key?(field)
          document[field].each {|t| type = t unless t == "Original" or t == "Raw"}
        end
      end
      if type.nil?
        type_format = '%s'
      else
        type_format = type + ' (%s)'
      end
    else
      type_format = '%s'
    end

    type_format
  end

  def params_for_search(options={})
    # special keys
    # params hash to mutate
    source_params = options.delete(:params) || params
    omit_keys = options.delete(:omit_keys) || []

    # params hash we'll return
    my_params = source_params.dup.merge(options.dup)


    # remove items from our params hash that match:
    #   - a key
    #   - a key and a value
    omit_keys.each do |omit_key|
      case omit_key
        when Hash
          omit_key.each do |key, values|
            next unless my_params.has_key? key

            # make sure to dup the source key, we don't want to accidentally alter the original
            my_params[key] = my_params[key].dup

            values = [values] unless values.respond_to? :each
            values.each {|v| my_params[key].delete(v)}

            if my_params[key].empty?
              my_params.delete(key)
            end
          end

        else
          my_params.delete(omit_key)
      end
    end

    if my_params[:page] and (my_params[:per_page] != source_params[:per_page] or my_params[:sort] != source_params[:sort])
      my_params[:page] = 1
    end

    my_params.reject! {|k, v| v.nil?}

    # removing action and controller from duplicate params so that we don't get hidden fields for them.
    my_params.delete(:action)
    my_params.delete(:controller)
    # commit is just an artifact of submit button, we don't need it, and
    # don't want it to pile up with another every time we press submit again!
    my_params.delete(:commit)

    my_params
  end

  # Create form input type=hidden fields representing the entire search context,
  # for inclusion in a form meant to change some aspect of it, like
  # re-sort or change records per page. Can pass in params hash
  # as :params => hash, otherwise defaults to #params. Can pass
  # in certain top-level params keys to _omit_, defaults to :page
  def search_as_hidden_fields(options={})
    my_params = params_for_search({:omit_keys => [:page]}.merge(options))

    # hash_as_hidden_fields in hash_as_hidden_fields.rb
    return hash_as_hidden_fields(my_params)
  end


  def link_to_previous_document(previous_document)
    if (!previous_document.nil?)
      collectionName = Array(previous_document[MetadataHelper.short_form(MetadataHelper::COLLECTION)]).first
      itemIdentifier = previous_document[:handle].split(':').last

      link_to catalog_url(collectionName, itemIdentifier), :class => "previous", :rel => 'prev', :'data-counter' => session[:search][:counter].to_i - 1 do
        content_tag :span, raw(t('views.pagination.previous')), :class => 'previous'
      end
    else
      content_tag :span, raw(t('views.pagination.previous')), :class => 'next'
    end
  end

  def link_to_next_document(next_document)
    if (!next_document.nil?)
      collectionName = Array(next_document[MetadataHelper.short_form(MetadataHelper::COLLECTION)]).first
      itemIdentifier = next_document[:handle].split(':').last

      link_to catalog_url(collectionName, itemIdentifier), :class => "next", :rel => 'next', :'data-counter' => session[:search][:counter].to_i + 1 do
        content_tag :span, raw(t('views.pagination.next')), :class => 'next'
      end
    else
      content_tag :span, raw(t('views.pagination.next')), :class => 'next'
    end
  end

  # Use case, you want to render an html partial from an XML (say, atom)
  # template. Rails API kind of lets us down, we need to hack Rails internals
  # a bit. code taken from:
  # http://stackoverflow.com/questions/339130/how-do-i-render-a-partial-of-a-different-format-in-rails (zgchurch)
  def with_format(format, &block)
    old_formats = formats
    self.formats = [format]
    block.call
    self.formats = old_formats
    nil
  end

  # puts together a collection of documents into one refworks export string
  def render_refworks_texts(documents)
    val = ''
    documents.each do |doc|
      if doc.respond_to?(:to_marc)
        val += doc.export_as_refworks_marc_txt + "\n"
      end
    end
    val
  end

  # puts together a collection of documents into one endnote export string
  def render_endnote_texts(documents)
    val = ''
    documents.each do |doc|
      if doc.respond_to?(:to_marc)
        val += doc.export_as_endnote + "\n"
      end
    end
    val
  end

  def render_display_text(url)
    begin
      text = open(url) {|f| f.read}.strip.force_encoding("UTF-8")
      return "<div class='primary-text'>#{text}</div>"
    rescue => e
      Rails.logger.error e.message
      return render_no_display_document
    end
  end

  def render_no_display_document
    return "<em>This Item has no display document</em>"
  end

  def item_documents(solr_document, uris)
    document_descriptors = []
    item = Item.find_by_handle(solr_document[:handle])
    begin
      server = RDF::Sesame::HcsvlabServer.new(SESAME_CONFIG["url"].to_s)
      repository = server.repository(item.collection.name)
      raise Exception.new "Repository not found - #{item.collection.name}" if repository.nil?
      document_results = repository.query(:subject => RDF::URI.new(item.uri), :predicate => RDF::URI.new(MetadataHelper::DOCUMENT))
      document_results.each {|result|
        document = result.to_hash[:object]
        descriptor = {}

        uris.each {|uri|
          field_results = repository.query(:subject => document, :predicate => uri)
          unless field_results.size == 0
            descriptor[uri] = field_results.first_object
          end
        }
        document_descriptors << descriptor
      }
    rescue => e
      Rails.logger.error "Could not connect to triplestore - #{SESAME_CONFIG["url"].to_s}"
      return document_descriptors
    end

    # KL - to show contribution link in item show page
    # append document id and contribution id (if document has association to contribution, otherwise nil)
    document_descriptors.each do |d|
      # ensure doc type & size info is not empty
      if d[MetadataHelper::TYPE].nil?
        d[MetadataHelper::TYPE] = ContributionsHelper.extract_doc_type(d[MetadataHelper::IDENTIFIER].to_s)
      end

      #   find document by item id and file_name
      doc = Document.where(item_id: item.id, file_name: d[MetadataHelper::IDENTIFIER].to_s)
      if !doc.nil? && !doc.first.nil?
        d[:handle] = item.handle
        d[:document_id] = doc.first.id

        if d[MetadataHelper::EXTENT].nil?
          d[MetadataHelper::EXTENT] = File.size?(doc.first.file_path)
        end

        cm = ContributionMapping.find_by_document_id(doc.first.id)
        if !cm.nil?
          d[:contribution_id] = cm.contribution_id
        end
      end
    end

    return document_descriptors
  end

  def collection_show_fields(collection)
    graph = collection.rdf_graph
    fields = graph.statements.map {|i| {collection_label(MetadataHelper::short_form(i.predicate)) => collection_value(graph, i.predicate)}}.uniq

    # fields << {'SPARQL Endpoint' => catalog_sparqlQuery_url(collection.name)}
    fields << {'Owner' => "#{@collection.owner.full_name} (#{@collection.owner.email})"}
    # logger.debug "collection_show_fields: #{fields.inspect}"

    fields
  end

  def collection_label(key)
    config = YAML.load_file("#{Rails.root.to_s}/config/collection_label_map.yml")
    if config["labels"][key].nil?
      key
    else
      config["labels"][key]
    end
  end

  def collection_value(graph, field)
    matching = graph.find_all {|st| st.predicate == field}
    if matching.count == 1
      return matching.first.object
    else
      return format_duplicates(matching.map {|i| i.object})
    end
  end

  #
  # =============================================================================
  # Utility Formatting methods
  # =============================================================================
  #

  #
  # SI bsed formatting of a physical quantity (ie. a number with a unit).
  #
  def format_extent(value, unit, multiple = 1000)
    prefix = ['E', 'P', 'T', 'G', 'M', 'k', '', 'm', 'u', 'n', 'p', 'f', 'a']
    p_idx = prefix.find_index('')

    while value.abs > multiple
      value = 1.0 * value # force it to floating point
      value /= multiple
      p_idx -= 1
      break if p_idx == 0
    end
#    while value.abs <= 1.0
#      value *= multiple
#      p_idx += 1
#      break if p_idx == prefix.size-1
#    end
    if value.is_a?(Fixnum)
      return sprintf("%4d %s%s", value, prefix[p_idx], unit)
    else
      return sprintf("%4.1f %s%s", value, prefix[p_idx], unit)
    end

  end

  def format_key(uri)
    uri = last_bit(uri).sub(/_tesim$/, '')
    uri = uri.sub(/^([A-Z]+_)+/, '') unless uri.starts_with?('RDF')
    return uri
  end

  def format_value(list)
    return list unless list.is_a?(Array)
    list.join(', ')
  end

  #
  # Extract the last part of a path/URI/slash-separated-list-of-things
  #
  def last_bit(uri)
    str = uri.to_s # just in case it is not a String object
    return str.split('/')[-1]
  end

  #
  # Format a list of things with duplicates as a list showing counts
  # e.g. ["one", "one", "two", "three", "two"] should come out as
  # "one (x2), two(x2), three".
  #
  def format_duplicates(list)
    return "" if list.nil?
    return list unless list.respond_to?("each")
    hash = {}
    list.each {|item|
      if hash.has_key?(item)
        hash[item] += 1
      else
        hash[item] = 1
      end
    }
    new_list = []
    list.each {|k|
      if hash.has_key?(k)
        count = hash[k]
        if count == 1
          new_list << k
        else
          new_list << "#{k} (x#{hash[k]})"
        end
        hash.delete(k)
      end
    }
    return new_list.join(', ')
  end

  #
  # End of Utility Formatting methods
  # -----------------------------------------------------------------------------
  #

  #
  # =============================================================================
  # Language Code methods
  # =============================================================================
  #
  def language_query_sil_base_uri()
    return "http://www-01.sil.org/iso639-3/documentation.asp?id="
  end

  def language_query_ethnologue_base_uri()
    return "http://www.ethnologue.com/language/"
  end

  def language_query_base_uri()
    config = YAML.load_file("#{Rails.root.to_s}/config/linguistics.yml")[Rails.env]
    return config["iso639_3_code_lookup_url"].to_s
  end

  def language_query_uri(iso639_3_code)
    return URI(sprintf(language_query_base_uri, iso639_3_code))
  end

  #def language_regexp()
  #  return /<h1 class="title" id="page-title">\s*(\S+)\s*<\/h1>/
  #end

  #def language_name(iso639_3_code)
  #  begin
  #    xml = language_query_uri(iso639_3_code).read
  #    match = language_regexp().match(xml)
  #    return iso639_3_code + " - regexp fail" if match.nil?
  #    return match[1]
  #  rescue
  #    return iso639_3_code + " - rescue"
  #  end
  #end

  def render_language_code(iso639_3_code)
    if iso639_3_code != "unspecified"
      "<a href=\"#{language_query_uri(iso639_3_code)}\">#{iso639_3_code}</a>"
    else
      iso639_3_code
    end
  end

  def render_language_codes(list)
    return (list.map {|c| render_language_code(c)}).join(', ')
  end
  #
  # End of Language Code methods
  # -----------------------------------------------------------------------------
  #

end

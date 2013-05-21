require 'blacklight/catalog'

require 'ostruct'

class TranscriptsController < ApplicationController
  respond_to :html, :xml

  include Blacklight::Catalog
  include Blacklight::BlacklightHelperBehavior

  before_filter :authenticate_user!

  MEDIA_ITEM_FIELDS = %w(title description recorded_on copyright license format media depositor)

  def show
    @transcript = load_transcript
    @media_item = load_media params['id']

    logger.warn "Test: #{@media_item.inspect}"    
  end


  def load_transcript
    file = OpenStruct.new
    file.path = '/Users/ilya/Downloads/eopas.xml'
    source = OpenStruct.new
    source.file = file
    depositor = OpenStruct.new
    depositor.full_name = "Joe Bloggs"
    params = { source: source, transcript_format: 'EOPAS', depositor: depositor, title: 'Test', date: '2000-04-07 00:00:00 UTC', country_code: 'AU', language_code: 'eng'}
    transcript = Transcript.new params
    transcript.create_transcription
    transcript
  end

  def load_media(item_id)
    documents = get_solr_response_for_doc_id(item_id)[0]
    document = documents['response']['docs'][0]
    attributes = document_to_attribues(document)
    media = get_media('video', params['url'])
    attributes['media'] = media
    media_item = MediaItem.new attributes
    media_item
  end

  def solr_doc_to_hash(solr_document)
    result = {}
    solr_document.each do |key, value|
      key = key.split('/')[-1].split('#')[-1].split('_')[0..-2].join('_')
      value = value[0] unless value.size > 1
      result[key] = value
    end
    result
  end

  def get_media(type, url)
    media = OpenStruct.new
    if type == 'audio'
      audio = OpenStruct.new
      audio.url = url
      media.audio = audio
    elsif type == 'video'
      video = OpenStruct.new
      video.url = url
      video.url = 'http://eopas.rnld.unimelb.edu.au/system/media_item/originals/21/video/NT5-TokelauThatch-Vid104.ogg'
      media.video = video
      poster = OpenStruct.new
      poster.url = 'http://konstantkitten.com/wp-content/uploads/kittne4.jpg'
      media.poster = poster
    end
    media
  end

  def document_to_attribues(document)
    attributes = solr_doc_to_hash(document)  
    attributes['format'] = 'video'

    attributes['recorded_on'] = attributes['created']
    attributes['copyright'] = attributes['rights']
    attributes['license'] = attributes['rights']

    depositor = OpenStruct.new
    depositor.full_name = attributes['depositor']
    attributes['depositor'] = depositor

    attributes.delete_if {|key, value| !MEDIA_ITEM_FIELDS.include? key}
    attributes
  end

end

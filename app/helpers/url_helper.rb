module UrlHelper
  #
  # Retrieves the document relative url
  #
  extend ActiveSupport::Concern
  include Rails.application.routes.url_helpers

  included do
    def default_url_options
      Rails.application.routes.default_url_options
    end
  end


  def self::getDocumentUrl(doc)
    return "/catalog/#{doc.item.id}/document/#{doc.file_name.first}"
  end
end

class UrlGenerator
  include UrlHelper
end

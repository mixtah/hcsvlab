module LicenceHelper

  # Return default licence object.
  # If no licence retrieve according to input licence id, return default licence (Creative Commons v3.0 BY) instead
  def self.licence(licence_id)
    lic = nil
    begin
      lic = Licence.find_by_id(licence_id)
    rescue Exception => e
      logger.error "licence: cannot find licence by id[#{licence_id}]: #{e.message}"
    ensure
      if lic.nil?
        lic = Licence.find_by_name('Creative Commons v3.0 BY')
      end
    end

    lic
  end

end
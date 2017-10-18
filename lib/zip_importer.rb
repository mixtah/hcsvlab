require 'zip/zip'

class ZipImporter

    def initialize(dir, zip_file, metadata_file)
        # @zip_path = zip_path
        # @metadata_path = metadata_path

        @dir = dir
        @zip_file = zip_file
        @metadata_file = metadata_file
    end

    def import
        extract_zip


    end

    def extract_zip
        # dir = File.dirname(@zip_path)
        # basename = File.basename(@zip_path)
        
        zip_path = File.join(@dir, @zip_file)
        puts "Importing #{zip_path}"

        Zip::ZipFile.open(zip_path) { |z|
            z.each { |f|
                f_path=File.join(@dir, f.name)
                FileUtils.mkdir_p(File.dirname(f_path))
                z.extract(f, f_path) unless File.exist?(f_path)
            }
        }
    end
end
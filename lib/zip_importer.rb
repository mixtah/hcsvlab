require 'zip/zip'
require 'pathname'

module AlveoUtil
    class ZipImporter

        def initialize(dir, zip_file, options={})
            @dir = dir
            @zip_file = zip_file
            @options = options ? options : {}
            @import_dir = Rails.application.config.upload_location
            @files = nil
            @warnings = []
            @documents = {}
        end

        # Extract the zip and return a list of files we will consider
        # Generally you would call this first
        # But not required if the file is already unzipped
        def extract
            extract_zip
            @files ||= find_importable_files
            return @files
        end

        # From the list of files on disk, derive a list of items based on our import settings
        def items
            @documents ||= find_documents
            @documents.keys
        end

        def item_metadata
            @documents ||= find_documents
            @item_metadata
        end

        def item_metadata_fields
            @documents ||= find_documents
            @item_metadata_fields
        end

        def total_items
            items.size
        end

        def total_files
            @documents ||= find_documents
            @files.size
        end

        def warnings
            @warnings
        end

        # From the list of files on disk, derive a list of documents based on our import settings
        # Grouped by item
        def find_documents
            @files ||= find_importable_files
            return @documents if @documents.size > 0

            @documents = {}
            @item_metadata = {}
            @item_metadata_fields = []
            @duplicates = []
            total = 0

            @files.each do |f|
                i = item_name(f)
                @documents[i] = {} unless @documents[i]

                # Basename of the document
                name = document_name(f)

                # Filename extension 
                dot_ext = File.extname(f)
                # Without period
                ext  = dot_ext.gsub('.','').downcase
                size = File.size(f)

                if !@documents[i].key?(name+dot_ext)
                    total = total + 1
                    @documents[i][name+dot_ext] = {
                        file: f,
                        meta: {
                            "dcterms:title"  => name,
                            "dcterms:extent" => size,
                            "dcterms:type"   => ext,
                        }
                    }
                    # Add extra meta data, extracted from filename
                    if @options['meta_in_filename']
                        @item_metadata[i] = {}
                        bits = name.split(@options['meta_delimiter'])
                        x = 0
                        bits.each do |bit|
                            if @options['meta_fields'].is_a?(Array) and !@options['meta_fields'][x].blank?
                                meta_term = @options['meta_fields'][x]
                                
                                # Collect into global list
                                @item_metadata_fields << meta_term unless @item_metadata_fields.include? meta_term
                                # Collect into item list
                                if @item_metadata[i][meta_term] != bit
                                    set_warning("We found more than one value for the \"#{meta_term}\" item field across all files. Using the last one.")
                                end
                                @item_metadata[i][meta_term] = bit
                            end
                            x = x + 1
                        end
                    end
                else
                    @duplicates << (name + dot_ext)
                end
            end
            
            fcount = @files.count
            dcount = @duplicates.size

            if fcount != total
                set_warning("File count (#{fcount}) does not match document count (#{total})")
            end

            if dcount > 0
                set_warning("#{dcount} duplicate files were found within the same item: " + @duplicates.join(', '))
            end

            return @documents
        end

        protected

        # Derive an item name from a file name
        def item_name(file_name)
            # By default, the item name will just be the filename without extension
            name = File.basename(file_name, File.extname(file_name))

            # Specify a truthy folders_as_item_names if we want to create items 
            # based on folder names, like 'SP1' in:
            #
            #	myfolder/SP1/one.txt
            #	myfolder/SP1/two.txt
            #	
            # The user should also choose at what folder depth the item folders 
            # are, as an index relative to the unzip root. Example for depth 2:
            #
            #	children-sample-upload/children/SP1/data/file.txt
            #	children-sample-upload/children/SP1/labels/file.txt
            #	children-sample-upload/children/SP2/data/file.txt
            #	children-sample-upload/children/SP2/labels/file.txt
            # 
            # Example for items at depth 3:
            # 
            #   children-sample-upload/children/data/SP1/file.txt
            #   children-sample-upload/children/data/SP2/file.txt
            #   children-sample-upload/children/labels/SP1/file.txt
            #   children-sample-upload/children/labels/SP2/file.txt
            #            
            if @options['folders_as_item_names'] and @options['item_name_at_folder_depth'].to_i > 0

                import_dir = Pathname.new(@import_dir)
                full_path = Pathname.new(file_name)
                relative = full_path.relative_path_from(import_dir)

                path_bits = relative.to_s.split('/')
                if (path_bits.size - 1) > @options['item_name_at_folder_depth'].to_i
                    name = path_bits[ @options['item_name_at_folder_depth'] ]
                else
                    w = "Invalid folder depth specified - ignoring"
                    @warnings << w unless @warnings.include?(w)
                end
            end

            return name.downcase.delete(' ./') # Same logic as sanitise_name
        end

        def set_warning(warning)
            @warnings << warning unless @warnings.include?(warning)
        end

        # Derive a document name from a file name
        def document_name(file_name)
            File.basename(file_name, File.extname(file_name))
        end

        # Unzip the file preserving folder structure
        # 
        def extract_zip
            begin
                zip_path = File.join(@dir, @zip_file)

                Zip::ZipFile.open(zip_path) { |z|
                    z.each { |f|
                        f_path = File.join(@dir, f.name)
                        FileUtils.mkdir_p(File.dirname(f_path)) unless File.exist?(File.dirname(f_path))
                        z.extract(f, f_path) unless File.exist?(f_path)
                    }
                }
            rescue Exception => e
                puts e
                return false
            end
        end

        def find_importable_files
            # Ignore these file types
            ignore_file_suffixes = ['', '.zip','.xls','.xlsx','.csv']

            files = Dir[ File.join(@dir, '**', '*') ].reject { |p| 
                File.directory?(p) ||
                !File.readable?(p) ||
                ignore_file_suffixes.include?(File.extname(p))
            }
            
            @warnings << "No valid files were found. Please check your zip file and try uploading again." if files.size < 1

            return files
        end
    end
end

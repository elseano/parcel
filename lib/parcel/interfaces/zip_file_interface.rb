module Parcel
    module Interfaces

        class ZipFileInterface < ScratchSpaceBase
            File = Struct.new(:name, :size)

            # Returns all the files present in the repository.
            def files
                return [] unless @scratch.exist?("original")

                result = Array.new
                Zip::ZipFile.foreach(@scratch.path("original")) { |entry| result << File.new(entry.name, entry.size) }
                result
            end
          
            # Returns the contents of the given file. Supports wildcard matching, 
            # in which case returns the contents of the first file found.
            def read_file(filename)
                return nil unless @scratch.exist?("original")

                if @scratch.exist?("extracted_#{filename}")
                    return IO.read(@scratch.path("extracted_#{filename}"))
                end

                if filename =~ /[\*\?]/         
                    file_match = Regexp.new("^" + filename.gsub(".", "\\.").gsub("*", ".*").gsub("?", ".") + "$", Regexp::IGNORECASE)

                    Zip::ZipFile.foreach(@scratch.path('original')) do |entry|
                        if entry.name =~ file_match
                            read_file = @scratch.path("extracted_#{entry.name}")
                            entry.extract(read_file)

                            return IO.read(read_file)
                        end
                    end

                    return nil
                else
                    Zip::ZipFile.open( @scratch.path('original'), Zip::ZipFile::READ ) do |reader|
                        if entry = reader.find_entry(filename)
                            extracted_path = @scratch.path("extracted_#{entry.name}")
                            entry.extract extracted_path

                            return IO.read(extracted_path)
                        else
                            return nil
                        end
                    end
                end
            end
          
            # Adds a file to the repository.
            def add_file(filename, contents_or_stream)
                @scratch.delete("extracted_#{filename}")

                Zip::ZipFile.open( @scratch.path('original'), Zip::ZipFile::CREATE ) do |writer|
                    writer.get_output_stream(filename) do |file|
                        if contents_or_stream.respond_to?(:read)
                            IO.copy_stream(contents_or_stream, file)
                        else
                            file.write contents_or_stream
                        end
                    end
                end
            end

        end

    end
end

Parcel.register_interface :zip, Parcel::Interfaces::ZipFileInterface

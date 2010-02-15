require 'fileutils'
require 'zip/zip'
require 'ostruct'

module Parcel
  
  # The FileRepository class represents a compressed archive of files
  # providing an easy interface for enumerating and updating the contents.
  class ZipFileRepository
  
    # Create a blank FileRepository, or open one from an existing file object.
    def initialize(owner = nil, options = Hash.new)
      @temp_file = Parcel.temp_path("#{owner.object_id}_#{rand(99999)}.zip")
      @owner = owner
      @name = options[:name]
    end
    
    def import(source)
      File.open(@temp_file, "w") { |f| f.write source.read }
    end
    
    def import_data(data)
      File.open(@temp_file, "w") { |f| f.write data }
    end
    
    def commit_path
      @owner.parcel_data_path(@name) + ".zip"
    end
  
    # Returns true if there are no files in the repository, or if the attachment is nil.
    def blank?
      files.blank?
    end
    
    # Clears the repository.
    def clear!
      File.unlink(@temp_file) if File.exist?(@temp_file)
      
      Zip::ZipFile.open( @temp_file, Zip::ZipFile::CREATE ) do
      end
    end
  
    # Returns all the files present in the repository.
    def files
      return [] if @temp_file.nil? || !File.exist?(@temp_file)
    
      result = Array.new
      Zip::ZipFile.foreach(@temp_file) { |entry| result << OpenStruct.new(:name => entry.name, :size => entry.size) }
      result
    end
  
    # Returns the contents of the given file. Supports wildcard matching, 
    # in which case returns the contents of the first file found.
    def read_file(filename)
      return nil if blank?
    
      file_match = Regexp.new("^" + filename.gsub(".", "\\.").gsub("*", ".*").gsub("?", ".") + "$", Regexp::IGNORECASE)
    
      Zip::ZipFile.foreach(@temp_file) do |entry|
        if entry.name =~ file_match
          read_file = Parcel.temp_path(File.basename(entry.name))
          entry.extract(read_file)
          result = IO.read(read_file)
          File.unlink(read_file)
          return result
        end
      end
    
      return nil
    end
  
    # Adds a file to the repository.
    def add_file(filename, contents)
      Zip::ZipFile.open( @temp_file, Zip::ZipFile::CREATE ) do |writer|
        writer.get_output_stream(filename) { |file| file.write contents }
      end
    end
  
    # Returns an open file stream of the repository.
    def to_file
      blank? ? nil : File.open(@temp_file)
    end
    
    def save_to(destination)
      FileUtils.mkdir_p(File.dirname(destination))
      FileUtils.cp(@temp_file, destination) if @temp_file && File.exist?(@temp_file)
    end
    
    def commit!
      raise ArgumentError, "No owner defined, use \#save_to instead" if @owner == nil
      save_to(commit_path)
    end
  
  end
  
  
end
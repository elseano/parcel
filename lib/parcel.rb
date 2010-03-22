require File.join(File.dirname(__FILE__), "parcel", "has_parcel")
require File.join(File.dirname(__FILE__), "parcel", "zip_file_repository")

module Parcel
  
  @options = Hash.new
  
  def self.storage_root
    @options[:storage_root] || "./:class_name/:id"
  end
  
  def self.storage_root=(value)
    @options[:storage_root] = value
  end
  
  def self.temp_path(filename)
    date_stamp = "%04d_%02d_%02d" % [Time.now.year, Time.now.month, Time.now.day]
    path = File.join(temp_root, date_stamp, "#{Time.now.to_i}_#{rand(999999)}_#{filename}")
    FileUtils.mkdir_p( File.dirname(path) )
    path
  end
  
  def self.temp_root=(value)
    @options[:temp_root] = value
  end
  
  def self.temp_root
    @options[:temp_root] || "/tmp/parcel"
  end
  
  def self.underscore(camel_cased_word)
    camel_cased_word.to_s.gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("-", "_").
      downcase
  end
  
  def self.interpolate_path(path, options, reference)
    new_path = path.to_s
    
    framework_opts = Hash.new
    if defined?(Rails)
      framework_opts[:rails_root] = Rails.root
      framework_opts[:id] = reference.id if reference.is_a?(ActiveRecord::Base)
    end
    
    framework_opts[:id] ||= reference.object_id
    
    merge_opts = framework_opts.merge({ :class_name => underscore(reference.class.name) }).merge(options)
    
    merge_opts[:id] = ("%08d" % merge_opts[:id].to_s).scan(/..../)
    
    merge_opts.to_a.sort_by { |(k,v)| -k.to_s.length }.each do |(k,v)|
      new_path = new_path.gsub(":#{k}", v.to_s)
    end
    
    new_path
  end
  
  def self.create_repository(owner, options, source = nil)
    repo = if options[:class] == :zip
      ZipFileRepository.new(owner, options)
    else
      nil
    end
    
    raise ArgumentError, "Repository not supported: #{options[:class]}" if repo.nil?
    
    if source.is_a?(String) && source.starts_with?("/")
      repo.import(File.open(source, "r"))
    elsif source.is_a?(String)
      repo.import_data(source)
    elsif source.respond_to?(:to_file)
      repo.import(source.to_file)
    elsif source.respond_to?(:read)
      repo.import(source)
    elsif File.exist?(repo.commit_path)
      repo.import(File.open(repo.commit_path, "r"))
    end
    
    repo
  end
  
end

Object.send(:include, Parcel::HasParcel)
Gem::Specification.new do |spec|
  spec.author = "Sean St. Quentin"
  spec.files = ["lib/parcel.rb", "lib/parcel/has_parcel.rb", "lib/parcel/zip_file_repository.rb"]
  spec.add_dependency "rubyzip"
  spec.description = <<-EOF
    Parcel is a simple library which allows normal ruby objects to maintain a series
    of files stored in one or more repositories which are accessible through normal ruby attributes.
    Possible repositories include Zip Files, Tar Files, Subversion Repos, Repos, GridFS Zips, etc.
    It also provides an common and easy to use interface to all these repositories (i.e. more ruby like than RubyZip), and
    works with ActiveRecord but doesn't depend on it.
  EOF
  spec.name = "parcel"
  spec.summary = "Simple repository management"
  spec.version = "0.4"
  spec.homepage = "http://github.com/elseano/parcel"
end
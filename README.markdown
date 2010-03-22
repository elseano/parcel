# Parcel
A simple ruby library for managing zip files and associating them with classes or Rails models.

# Usage - Plain Old Ruby

Using parcel is simple with just normal ruby objects, although right now you will want to override the `parcel_data_path` method if you want your parcel files to be found between instantiations.

    class Job
      has_parcel :data
  
      def initialize(name)
        @name = name
        @file_path = name.scan(/\w+/i).join("_")
      end
  
      def parcel_data_path(filename)
        File.join("/Users/sean/jobs/", @file_path, filename)
      end
  
    end

    job = Job.new("test")
    job.data.add_file("data.txt", "This is some data that will be added to the job's data zip.")
    job.data.add_file("more_data.txt", "There is more data here.")

    # Save data to /Users/sean/jobs/test/data.zip
    job.commit_parcels!
    
Once accessed, the original parcel data is copied to a temporary file where all future access will be directed until `commit_parcels!` is called. Every parcel attached to a class allows you to add, list and read files within the parcel.
    
    # Read the files in the parcel.
    puts job.data.read_file("data.txt")
    # => "This is some data that will be added to the job's data zip."
    
    puts job.data.read_file("more_data.txt")
    # => "There is more data here."

    # Read the first .txt file in the parcel.
    puts job.data.read_file("*.txt")
    # => "This is some data that will be added to the job's data zip."
    
    # List each file and it's size.
    job.data.files.each do |file|
      puts "#{file.name} is #{file.size} bytes"
    end
    # => data.txt is 60 bytes
    # => more_data.txt is 25 bytes
    
    # Import an existing ZIP file.
    job.data = File.open("/tmp/some_temp_file.zip")
    
    # Wipe a parcel's data
    job.data.clear!
    
    # Is the parcel empty?
    job.data.blank?
    
    
# Usage - As a Rails model

Using parcel is also easy with ActiveRecord. By default it will store the parcels in directories composed using the model's table name and ID.

    # environment.rb
    Parcel.storage_root = File.join(Rails.root, "assets")
    Parcel.temp_root = File.join(Rails.root, "tmp/parcel")

    # job.rb
    class Job < ActiveRecord::Base
      has_parcel :data
    end

    job = Job.new
    job.data.add_file("data.txt", "This is some data that will be added to the job's data zip.")

    # data is automatically saved to "#{Rails.root}/assets/jobs/1/data.zip" after save.
    job.save!
    
    puts job.data.read_file("*.txt")              # => "This is some data that will be added to the job's data zip."
    job.data.files.each do |file|
      puts "#{file.name} is #{file.size} bytes"   # => data.txt is 60 bytes
    end

# Using parcel with uploaded files.

Parcel works with direct assignment from File and Rails upload objects - anything that responds to #read can be imported.

    job = Job.new
    job.data = params[:job][:uploaded_file]
    job.save!
    


# TODOs

* Allow filename interpolation of any model attribute.
* Better handle per-model storage location.
* Improve repository API to support other types of archives (tar, 7z, rar, git, svn, etc)
* Documentation and tests.
* Deleting files from a repository.
* Better cleanup of temporary files.
# Parcel
An extensible ruby library for storing and manipulating attached files. It's like paperclip, but more awesome.

Parcel can work by itself, or with ActiveRecord. The two main concepts behind parcel are Storage Methods and Interfaces.

## Storage Methods

The storage methods in parcel are responsible for the saving and loading of the file data. Built-in methods include:

* LocalStorage - Stores the file on the filesystem.
* AwsS3Storage - Stores the file on Amazon S3.
* WarehouseStorage - Manages transitioning files onto a slower but more permenant storage storage.

## Interfaces

The interfaces within parcel provide methods for you to manipulate the attachment. Built-in interfaces include:

* RMagickInterface - Read and obtain an RMagick instance of an attached image.
* ZipFileInterface - Read, add and remove files to a zip file.

# Usage

Using parcel is simple pretty straight forward. Here's an example of using parcel with active record:

    class Job < ActiveRecord::Base
        has_parcel :name => "data", :storage => :disk, :interface => :zip
    end

    job = Job.new
    job.data.add_file("data.txt", "This is some data that will be added to the job's data zip.")
    job.data.add_file("more_data.txt", "There is more data here.")

    job.save

    # Job ID is 1, so data was saved into the file /jobs/0001/data

# Configuration

There are a few configuration options available, some depdending on the Storage and Interfaces you're using.

## General Parcel Configuration

* `Parcel.scratch_class`: Allows you to change the scratch space class if you don't like Parcel writing temp files when manipulating the zip files.

## Scratch Space Configuration

You can change what location you'd like Parcel to use as Scratch Space.

* `Parcel::ScratchSpace.root=(value)`: The directory parcel will use as a scratch space. Defaults to "/tmp/".

The scratch space is used by interfaces. For example, the ZipFileInterface will make a copy of the original zip file into the scratch space which is then used by the `add_file`, `read_file`, etc methods. When the parcel is saved, the file is streamed from the scratch space back into whatever storage you're using. 

If you don't save the parcel after modification, the scratch space is discarded.

The scratch space hooks into the `ObjectSpace.define_finalizer` method to delete its directory when garbage collected.

# Storage Options

Storage classes are registered using the following syntax:

    Parcel.register_storage(alias, class)

Registrations replace previous registrations, so you can swap out default Parcel implementations for your own in situations where you can't change the storage option provided to `has_parcel`.

For example:

    Parcel.regsiter_storage :disk, MyCustomApp::Storage::DiskStorage

All storage classes must inherit from `Parcel::Storage::Base`, and implement the methods described there. All storage methods must handle streams, and the `read` method must yield a stream handle. See the comments on the `Base` class for more information.

## Using LocalStorage

The LocalStorage has one configuration option, which allows you to specify what the root path is for storage of assets.

* `Parcel::Storage::LocalStorage.root=(value)`: Set the root directory of where you'd like parcel to start storing data.

In addition to this, the method `parcel_path` is used to indicate a path under `root` to use for the instance storage directory. If you're using `ActiveRecord` then this is provided for you and generates a path like the following:

* `Job#12345` -> `/jobs/0001/2345/12345/`
* `NameSpace::User#4` -> `/name_space/users/0004/4/`

## Using AwsS3Storage

The AWS S3 storage uses the `aws-s3` gem. The configuration is performed by the `establish_connection!` method on that library.

    AWS::S3::Base.establish_connection!(
        :access_key_id     => 'abc',
        :secret_access_key => '123'
    )

The name of the S3 asset is prefixed with the `parcel_path` value. See the `LocalStorage` usage for details on how this works.

The S3 storage requires a bucket name to be provided to `has_parcel`. Example:

    class Data
        has_parcel :log, :interface => :zip, :storage => :s3, :bucket => "zip-files"
    end


## Using WarehouseStorage

The warehouse storage method requires two additional options provided to has_parcel, as well as any options required by the two additional storage methods.

    class AnotherClass
        has_parcel :log, :interface => :log_file, :storage => :warehouse, :fast_storage => :disk, :warehouse_storage => :s3, :bucket => "logs"
    end

When a parcel uses the Warehouse storage method, all parcels are stored using the `fast_storage` option, until the `warehouse!` method is called. At that point the parcel is moved from the `fast_storage` to the `warehouse_storage`. This move is reverted if the parcel is accessed again.

# Interface Options

Interface classes are regsitered using the following syntax:

    Parcel.register_interface(alias, class)

Like the Storage options, registrations replace older ones. For example:

    Parcel.register_interface :git, MyCustomApp::Interfaces::GitInterface

All interface classes must inherit from `Parcel::Interfaces::Base`, or `Parcel::Interfaces::ScratchSpaceBase`, and implement the methods described there. See the comments on the `Base` class for more information.

# Using ZipFileInterface

TODO

# Using RMagickInterface

TODO


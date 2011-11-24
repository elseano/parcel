module Parcel

	# The scratch area is a special directory on a local hard drive which can be used to read and write temporary files.
	class ScratchArea

		attr_reader :root

		# Creates a proc to be called by ObjectSpace to cleanup the scratch directory.
		def self.finalize(root)
			proc { Parcel::ScratchArea.cleanup(root) }
		end

		# Set the default root of all created scratch spaces. By default, this is "/tmp"
		def self.root=(value)
			raise ArgumentError, "Root cannot be /" if File.expand_path(value) == "/"
			@root = value
		end

		def self.root
			@root
		end

		# Remove the scratch space in the given path. Only allows directories under "root" to be removed.
		def self.cleanup(path)
			return if path.nil?
			return unless path =~ /^#{@root}/

			FileUtils.rm_rf(path) if File.exist?(path)
		end

		# Generates a scratch space directory name.
		def self.designate
			uuid_component = `uuidgen`.strip
			date_component = Time.now.strftime("%Y/%m/%d")

			File.join(@root, "parcel", date_component, uuid_component)
		end

		# Ensures the scratch space has been created on the hard drive, registers the scratch space directory
		# to be deleted when the object is disposed of, and returns the root of this current scratch space.
		def prepared_root
			@root ||= begin
				dir = Parcel::ScratchArea.designate
				FileUtils.mkdir_p(dir)
				ObjectSpace.define_finalizer(self, self.class.finalize(dir))
				dir
			end
		end

		# Removes the current scratch space from the hard drive.
		def cleanup
			self.class.cleanup(root)
		end

		# Clears out the scratch space, ensuring it is empty.
		def reset!
			self.class.cleanup(prepared_root)
			FileUtils.mkdir_p(root)
		end

		# Opens a stream to a resource within the scratch space.
		def open(name, mode = "r")
			File.open("#{prepared_root}/#{name}", mode) { |f| return yield f }
		end

		# Reads the contents of the file into memory and returns it as a string.
		def read(name)
			IO.read(path(name)) if exist?(name)
		end

		# Works like +read+ but if the file doesn't exist, yields a block with
		# the new file so it can be created. Then returns the contents of the 
		# newly created file.
		def fetch(name)
			read(name) || begin
				open(name, "w") { |f| yield f }
				read(name)
			end
		end

		# Deletes a file from the scratch space.
		def delete(name)
			FileUtils.rm(path(name)) if exist?(name)
		end

		# Imports a file, stream, or data into the scratch space in one operation.
		def import(name, stream)
			open(name, "w") do |file|
				if stream.respond_to?(:read)
					FileUtils.copy_stream(stream, file)
				else
					file.write stream
				end
			end
		end

		# Returns the full path of a resource within the scratch space.
		def path(name)
			File.join(prepared_root, name.to_s)
		end

		# Indicates if a resource within the scratch space exists.
		def exist?(name)
			return false if @root.nil?
			File.exist?(path(name))
		end

	end
end
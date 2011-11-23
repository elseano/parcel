module Parcel
	module Storage
		class LocalStorage < Parcel::Storage::Base
			class << self
				attr_accessor :root
			end

			def path
				raise "You need to setup Parcel::Storage::LocalStorage.root" if self.class.root.nil?
				File.join(*[self.class.root, object.send(:parcel_path), name].reject { |x| x.to_s.length == 0 })
			end

			def write(data_stream)
				path = self.path

				FileUtils.mkdir_p(File.dirname(path))
				File.open(path, "w") { |output| FileUtils.copy_stream(data_stream, output) }
			end

			def read
				path = self.path
				return nil unless File.exist?(path)
				File.open(path, "r") { |input| yield input }
			end

			def delete
				FileUtils.rm_rf path
			end

		end
	end
end

Parcel.register_storage :disk, Parcel::Storage::LocalStorage

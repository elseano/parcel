module Parcel
	module Storage

		class AwsS3Storage < Base

			def path
				File.join(*[object.send(:parcel_path), options[:name]].reject { |x| x.to_s.length == 0 })
			end

			def write(stream)
				raise "You need to specify the bucket for has_parcel" if options[:bucket].nil?
				AWS::S3::S3Object.store(path(object, options), stream, options[:bucket])
			end

			def read
				Tempfile.open(path, Parcel::ScratchArea.root) do |file|
					AWS::S3::S3Object.stream(path, options[:bucket]) { |chunky| file.write chunky }
					yield file
				end
			end

			def delete
				
			end
		end

	end
end

Parcel.register_storage :s3, Parcel::Storage::AwsS3Storage

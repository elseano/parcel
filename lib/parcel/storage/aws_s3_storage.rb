module Parcel
	module Storage

		class AwsS3Storage < Base

			class << self

				def setup(aws_access_key_id, aws_secret_access_key)
					@aws = Aws::S3.new(aws_access_key_id, aws_secret_access_key)
				end

				def aws
					@aws
				end

			end

			def path
				File.join(*[object.send(:parcel_path), options[:name]].reject { |x| x.to_s.length == 0 })
			end

			def bucket
				raise "You need to specify the bucket for has_parcel" if options[:bucket].nil?
				@bucket ||= self.class.aws.bucket(options[:bucket])
			end

			def write(stream)
				key = bucket.key(path)
				key.put(stream)
			end

			def read
				key = bucket.key(path)

				filename = Tempfile.new("#{object_id}_#{Process.pid}", Parcel::ScratchArea.root).path

				File.open(filename, "w") do |file| 
					key.get { |chunky| file.write chunky }
				end

				File.open(filename) { |file| yield file }
				File.unlink(filename)
				
			rescue Aws::AwsError => ex
				raise unless ex.message =~ /^NoSuchKey/
			end

			def delete
				
			end
		end

	end
end

Parcel.register_storage :s3, Parcel::Storage::AwsS3Storage

module Parcel
	module Interfaces

		class RMagickInterface < ScratchSpaceBase
			ImageData = Struct.new(:columns, :rows, :format, :image_type)

			def meta_data
				@_meta_data ||= begin
					rmagick = self.image.first
					
					ImageData.new(rmagick.base_columns, rmagick.base_rows, rmagick.format, rmagick.image_type) if rmagick
				end
			end

			def data=(stream_or_data)
				if stream_or_data.is_a?(RMagick::ImageList)
					stream_or_data.write @scratch.path("original")
				else
					import(stream_or_data)
				end

				@meta_data = nil

				@images.each { |img| img.destroy! rescue nil } if @images
				@images = nil

				if options[:store_meta_data]
					write_meta_data
				end

				modified!
			end

			def write_meta_data
				if meta_data
					object.columns = meta_data.columns
					object.rows = meta_data.rows
					object.format = meta_data.format
					object.image_type = meta_data.image_type
				else
					object.columns = nil
					object.rows = nil
					object.format = nil
					object.image_type = nil
				end
			end

			def image
				images.first
			end

			def images
				@images ||= @scratch.open("original") do |file|
					RMagic::Image.read(file)
				end				
			end

		end

	end
end

Parcel.register_interface :image, Parcel::Interfaces::RMagickInterface

module Parcel
	module Storage
		class WarehousedError < StandardError; end

		# The warehouse storage option allows for two storage repositories, with the first
		# acting as a faster or more frequently accessed repository, and the second acting
		# as a slower longer term storage. For example, using Disk and S3 storage.
		#
		# To put an item into longer term storage, run #warehouse!. Fetching data will
		# try the fast storage first, and the warehouse second. If data is accessed from
		# the warehouse, it is placed into the fast storage.
		class WarehouseStorage < Base

			def fast_storage
				@fast ||= Parcel.storage(options[:fast_storage]).new(object, name, options)
			end

			def warehouse_storage
				@warehouse ||= Parcel.storage(options[:warehouse_storage]).new(object, name, options)
			end

			def write(data_stream)
				raise WarehousedError if warehoused?
				fast_storage.write(data_stream)
			end

			# Is the parcel currently warehoused?
			def warehoused?
				@warehoused == true
			end

			def read
				@warehoused = nil

				fast_storage.read do |input|
					yield input
					@warehoused = false
				end

				return if @warehoused == nil

				warehouse_storage.read do |input|
					yield input
					@warehoused = true
				end
			end

			# Deletes the data asset from both the warehouse and the fast storage.
			def delete
				fast_storage.delete
				warehouse_storage.delete
			end

			# Moves the data asset into the warehouse.
			def warehouse!
				return if warehoused?
				fast_storage.read do |input|
					warehouse_storage.write(input)
				end

				fast_storage.delete
				@warehoused = true

				object.send(options[:after_warehouse]) if options[:after_warehouse]
			end

			def retrieve!
				return unless warehoused?

				warehouse_storage.read do |input|
					fast_storage.write(input)
				end

				warehouse_storage.delete
				@warehoused = false

				object.send(options[:after_retrieve]) if options[:after_retrieve]
			end

		end

	end
end

Parcel.register_storage :warehouse, Parcel::Storage::WarehouseStorage

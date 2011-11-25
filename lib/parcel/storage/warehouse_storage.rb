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
		#
		# Warehouse state is stored on a warehoused active record attribute. Override this
		# class and its registration to integrate with other storage mechanisms.
		class WarehouseStorage < Base
			class << self
				attr_accessor :raise_warehoused_errors
				self.raise_save_errors = true
			end

			def fast_storage
				@fast ||= Parcel.storage(options[:fast_storage]).new(object, name, options)
			end

			def warehouse_storage
				@warehouse ||= Parcel.storage(options[:warehouse_storage]).new(object, name, options)
			end

			def write(data_stream)
				if warehoused?
					raise(WarehousedError, "Cannot save a warehoused file") if self.class.raise_save_errors
				else
					fast_storage.write(data_stream)
				end
			end

			# Is the parcel currently warehoused? Delegates to the warehoused indicator option.
			def warehoused?
				read_warehouse_state
			end

			def read
				if warehoused?
					warehouse_storage.read do |input|
						yield input
						@warehoused = true
					end
				else
					fast_storage.read do |input|
						yield input
						@warehoused = false
					end
				end
			end

			# Deletes the data asset from both the warehouse and the fast storage.
			def delete
				fast_storage.delete
				warehouse_storage.delete
			end

			# Moves the data asset into the warehouse. This can only warehouse a saved file,
			# so make sure the parcel has been written back to the fast storage before
			# warehousing. 
			def warehouse!
				return if warehoused?
				fast_storage.read do |input|
					warehouse_storage.write(input)
					write_warehouse_state(true)
				end

				raise(EmptyRepository, "Nothing to warehouse") unless warehoused?

				fast_storage.delete

				object.send(options[:after_warehouse]) if options[:after_warehouse]
			end

			def retrieve!
				return unless warehoused?

				warehouse_storage.read do |input|
					fast_storage.write(input)
					write_warehouse_state(false)
				end

				warehouse_storage.delete

				object.send(options[:after_retrieve]) if options[:after_retrieve]
			end

			protected

			def read_warehouse_state
				object.warehoused?
			end

			def write_warehouse_state(value)
				object.warehouse = value
				object.class.update_all("warehoused = #{value.to_s}", "id = #{object.id}")
			end

		end

	end
end

Parcel.register_storage :warehouse, Parcel::Storage::WarehouseStorage

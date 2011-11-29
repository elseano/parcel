module Parcel
	module Interfaces

		# The most basic of parcel interfaces. Generally you won't want to
		# inherit directly from this class unless you would like changed to object
		# through the interface to apply immediately to parcels. If you would like
		# protection from immediate changes, inherit the ScratchSpaceBase class
		# instead.
		class Base
			attr_reader :object, :name, :options

			def initialize(object, name, options)
				@object, @name, @options = object, name, options
			end

			# Yields the data stream of the interface data was modified.
			def stream(&block)
				return unless modified?
				stream!(&block)
			end

			# Accepts a block to which a data stream is yielded. It should
			# not yield if the data has not been modified. The yielded
			# stream must be able to be used with FileUtils.copy_stream.
			def stream!(&block)
				raise NotImplementedError
			end

			# Imports an existing stream into the interface. The steam
			# must be able to be used with FileUtils.copy_stream.
			def import(stream)
				raise NotImplementedError
			end

			# Marks the data as having been modified.
			def modified!
				@modified = true
			end

			# Returns true if the data stream was modified.
			def modified?
				@modified == true
			end

		end

	end
end
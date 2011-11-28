module Parcel
	module Interfaces

		class Base
			attr_reader :object, :name, :options

			def initialize(object, name, options)
				@object, @name, @options = object, name, options
			end

			# Accepts a block to which a data stream is yielded. It should
			# not yield if the data has not been modified. The yielded
			# stream must be able to be used with FileUtils.copy_stream.
			def stream
				raise NotImplementedError
			end

			# Imports an existing stream into the interface. The steam
			# must be able to be used with FileUtils.copy_stream.
			def import(stream)
				raise NotImplementedError
			end

		end

	end
end
module Parcel
	module Interfaces

		class Base
			attr_reader :object, :name, :options

			def initialize(object, name, options)
				@object, @name, @options = object, name, options
			end

			def stream
				raise NotImplementedError
			end

			def import(stream)
				raise NotImplementedError
			end

		end

	end
end
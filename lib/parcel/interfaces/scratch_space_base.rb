module Parcel
	module Interfaces

		class ScratchSpaceBase < Base
			attr_reader :scratch

			def initialize(*args)
				super
				@scratch = Parcel.scratch_class.new
			end

			def import(stream)
				@scratch.reset!
				@scratch.import("original", stream)
			end

			def stream
				@scratch.open("original") { |file| yield file }
			end
		end

	end
end
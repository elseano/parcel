module Parcel
	module Interfaces

		class ScratchSpaceBase < Base
			attr_reader :scratch

			def initialize(*args)
				super
				@scratch = Parcel.scratch_class.new
				@modified = false
			end

			def import(stream)
				@scratch.reset!
				@scratch.import("original", stream)
			end

			def stream
				return unless modified?
				@scratch.open("original") { |file| yield file }
			end

			def modified!
				@modified = true
			end

			def modified?
				@modified == true
			end
		end

	end
end
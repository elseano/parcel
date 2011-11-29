module Parcel
	module Interfaces

		# Represents an object format which can be freely modified
		# and wont persist changes back into the parcel unless it 
		# is saved. Allows changes to effectively be rolled back.
		class ScratchSpaceBase < Base
			attr_reader :scratch

			def initialize(*args)
				super
				@scratch = Parcel.scratch_class.new
				@modified = false
			end

			# Imports a data stream (open file, etc) into the scratch space
			# as the source file. If you are calling this through the proxy,
			# then remember to call modified! to ensure your imported data
			# is saved.
			def import(stream)
				@scratch.reset!
				@scratch.import("original", stream)
			end

			# Yields the data stream of the interface data was modified.
			def stream(&block)
				return unless modified?
				stream!(&block)
			end

			# Yields the data stream irrespective of modification.
			def stream!
				@scratch.open("original") { |file| yield file }
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
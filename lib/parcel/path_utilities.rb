module Parcel
	module PathUtilities

		class << self

			# Breaks down identifiers into directories so we don't overload
			# file system directory entries.
			#
			# 1 => 0001/1
			# 123 => 0123/123
			# 12345 => 0001/2345/12345
			# 123456789 => 0001/2345/6789/123456789
			def breakdown_integer(number)
				result = ("%020d" % number).scan(/..../) + [number.to_s]
				result.reject { |x| x == "0000" }
			end

		end

	end
end
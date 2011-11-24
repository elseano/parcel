module Parcel

	class << self 
		attr_accessor :scratch_class
	end

	require 'parcel/path_utilities'
	require 'parcel/proxy'
	require 'parcel/scratch_area'
	require 'parcel/registrations'

	module DSL
		require 'parcel/dsl/has_parcel'
		require 'parcel/dsl/active_record' if defined?(ActiveRecord::Base)
	end

	module Interfaces
		require 'parcel/interfaces/base'
		require 'parcel/interfaces/scratch_space_base'
		require 'parcel/interfaces/zip_file_interface'
		require 'parcel/interfaces/r_magick_interface'
	end

	module Storage
		require 'parcel/storage/base'
		require 'parcel/storage/local_storage'
		require 'parcel/storage/aws_s3_storage'
		require 'parcel/storage/warehouse_storage'
	end

end

require 'parcel/default_setup'

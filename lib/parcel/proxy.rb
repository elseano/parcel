module Parcel

	# Repositories should raise this exception to allow loading to fail.
	class EmptyRepository < StandardError; end

	# Manages access to the underlying parcel.
	class Proxy
		attr_reader :_format, :_backend

		def initialize(object, name, options)
			@object = object
			@_name = name
			
			format = options[:interface]
			backend = options[:storage]

			@_format = format.is_a?(Symbol) ? Parcel.resolve_interface(format).new(object, name, options) : format
			@_backend = backend.is_a?(Symbol) ? Parcel.resolve_storage(backend).new(object, name, options) : backend
		end

		# Yields the data stream from the interface. Used when saving the parcel. Is a no-op if
		# the parcel hasn't been accessed.
		def stream
			return unless @_proxy_prepared

			_format.stream { |f| yield f }
		end

		# Saves the parcel by sending the #stream to the backend.
		def save
			stream do |file|
				_backend.write(file)
			end
		end

		# Deletes the parcel from the backend.
		def delete
			_backend.delete
			@_proxy_prepared = false
		end

		# Prepares the parcel by loading the data into the interface.
		def prepare
			@_proxy_prepared ||= begin
				_backend.read do |file|
					_format.import(file)
				end
				true
			rescue EmptyRepository
				true
			end
		end

		# Delegates calls to the interface, or the storage if the interface
		# doesn't respond to the method.
		def method_missing(name, *args)
			prepare

			if _format.respond_to?(name)
				_format.send(name, *args)
			elsif _backend.respond_to?(name)
				_backend.send(name, *args)
			else
				super
			end
		end

	end
end
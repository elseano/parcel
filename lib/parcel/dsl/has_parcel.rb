module Parcel
	module DSL

		module HasParcel

			DEFAULT_OPTIONS = {
				:name => "parcel",
				:storage => :disk,
				:interface => :zip
			}

			def self.included(base)
				base.class_eval do
					extend ClassMethods
					include InstanceMethods
				end
			end

      # Takes the given stream and imports it into the repository.
      def self.process_uploaded_stream(stream, proxy)
        File.open(stream.path) do |file|
          proxy.import(file)
          proxy.modified!
        end
      end


			module ClassMethods

				# Specifies a parcel on a class.
				# Options:
				#
				# :name 		The name of the accessor method for the parcel (default 'parcel')
				# :storage		How the parcel should be stored. Can be an array for fallback attempts (default 'disk')
				# :interface	What kind of parcel do we want to provide (default 'zip')
				def has_parcel(*args)
					options = args.last.is_a?(Hash) ? args.pop : DEFAULT_OPTIONS
					raise ArgumentError, "options must be a hash" unless options.is_a?(Hash)
					options = DEFAULT_OPTIONS.merge(options)

					name = args.first.is_a?(String) || args.first.is_a?(Symbol) ? args.shift : options[:name]
					name = name.to_s
					options[:name] = name

					raise ArgumentError, "You must provide a name for the parcel" if name.to_s.strip.length == 0

					self.class_eval do
						eval %{
							def #{name}
								@_parcel_#{name} ||= Parcel::Proxy.new(self, #{name.inspect}, #{options.inspect})
							end


              def #{options[:name]}_uploaded=(value)
                Parcel::DSL::Parcel.process_uploaded_stream(value, #{options[:name]})
              end

						}

						if options[:path].is_a?(String)
							eval %{
								def parcel_path
									#{options[:path].inspect}
								end
							}
						else
							eval %{
								def parcel_path
									raise NotImplementedError
								end
							}
						end
					end

					options
				end
			end

			module InstanceMethods
			end

		end
	end
end

Object.send(:include, Parcel::DSL::HasParcel)
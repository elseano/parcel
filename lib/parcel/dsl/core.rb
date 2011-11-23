module Parcel
	module DSL

		module Core

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

			module ClassMethods

				# Specifies a parcel on a class.
				# Options:
				#
				# :name 		The name of the accessor method for the parcel (default 'parcel')
				# :storage		How the parcel should be stored. Can be an array for fallback attempts (default 'disk')
				# :interface	What kind of parcel do we want to provide (default 'zip')
				def has_parcel(options = {})
					raise ArgumentError, "options must be a hash" unless options.is_a?(Hash)
					options = DEFAULT_OPTIONS.merge(options)

					self.class_eval do
						eval %{
							def #{options[:name]}
								@_parcel_#{options[:name]} ||= Parcel::Proxy.new(self, #{options[:name].inspect}, #{options.inspect})
							end
						}

						eval %{
							def parcel_path
								raise NotImplementedError
							end
						}
					end

					options
				end
			end

			module InstanceMethods
			end

		end
	end
end

Object.send(:include, Parcel::DSL::Core)
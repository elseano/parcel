module Parcel
	module DSL

		# Adds callbacks for activerecord objects to save the parcel when the model has been saved.
		module ActiveRecord

			def self.included(base)
				base.class_eval do
					extend ClassMethods

					class << self
						alias_method_chain :has_parcel, :active_record
					end
				end
			end

			module ClassMethods
				def has_parcel_with_active_record(*args)
					options = has_parcel_without_active_record(*args)

					self.class_eval do
						eval %{
							def write_parcel_#{options[:name]}
								#{options[:name]}.save
							end

							def delete_parcel_#{options[:name]}
								#{options[:name]}.delete
							end

							def parcel_path
								raise Parcel::EmptyRepository, "Cannot read the repository for an unsaved ActiveRecord object." if id.nil?
								
								id_str = Parcel::PathUtilities.breakdown_integer(id).join('/')
								"\#{self.class.name.underscore}/\#{id_str}"
							end
						}
					end

					after_save "write_parcel_#{options[:name]}".to_sym
					after_destroy "delete_parcel_#{options[:name]}".to_sym
				end
			end

		end
	end
end

ActiveRecord::Base.send(:include, Parcel::DSL::ActiveRecord)
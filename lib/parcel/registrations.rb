module Parcel
	def self.register_interface(name, class_type)
		@interfaces ||= Hash.new
		@interfaces[name.to_sym] = class_type
	end

	def self.register_storage(name, class_type)
		@storages ||= Hash.new
		@storages[name.to_sym] = class_type
	end

	def self.resolve_interface(name)
		@interfaces[name.to_sym]
	end

	def self.resolve_storage(name)
		@storages[name.to_sym]
	end
end
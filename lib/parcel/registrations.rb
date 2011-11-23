module Parcel
	class InvalidInterface < StandardError; end
	class InvalidStorage < StandardError; end

	def self.register_interface(name, class_type)
		@interfaces ||= Hash.new
		@interfaces[name.to_sym] = class_type
	end

	def self.register_storage(name, class_type)
		@storages ||= Hash.new
		@storages[name.to_sym] = class_type
	end

	def self.interface(name)
		@interfaces ||= Hash.new
		@interfaces[name.to_sym] || raise(InvalidInterface, "Interface #{name} not found.")
	end

	def self.storage(name)
		@storages ||= Hash.new
		@storages[name.to_sym] || raise(InvalidStorage, "Storage #{name} not found.")
	end
end
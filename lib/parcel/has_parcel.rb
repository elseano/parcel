module Parcel
  module HasParcel
    def self.included(base)
      base.module_eval do
        extend ClassMethods
        include InstanceMethods
      end
    end
  
    module InstanceMethods
      def parcel_data_path(filename)
        data_path = File.join(Parcel.interpolate_path(Parcel.storage_root, Hash.new, self), filename.to_s)
        data_path
      end
      
      def commit_parcels!
        Array(instance_variables.select { |v| v =~ /\@_parcel_/ }).each do |name|
          instance = instance_variable_get(name)
          instance.commit! if instance
        end
        
        true
      end
      
      def destroy_parcels!
        FileUtils.rm_rf(self.class.parcel_data_path("."))
      end
    end
  
    module ClassMethods
    
      def has_parcel(name, options = {})
        options = { :class => :zip }.merge(options).merge({ :name => name })

        unless included_modules.include?(InstanceMethods)
          include(InstanceMethods)
          
          if defined?(ActiveRecord) && is_a?(ActiveRecord::Base)
            after_save :commit_parcels!
            after_destroy :destroy_parcels!
          end
        end
      
        define_method(name.to_sym) do
          instance_variable_get("@_parcel_#{name}") || begin
            parcel = Parcel.create_repository(self, options)
            instance_variable_set("@_parcel_#{name}", parcel)
            parcel
          end
        end
      
        define_method("#{name}=".to_sym) do |input|
          instance = instance_variable_get("@_parcel_#{name}")
          instance.destroy if instance
          
          instance_variable_set("@_parcel_#{name}", Parcel.create_repository(self, options, input))
        end
        
      end
    end
    
  end
end
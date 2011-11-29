module Parcel
  module Storage
    class Base
      attr_reader :object, :name, :options

      def initialize(object, name, options)
        @object, @name, @options = object, name, options
      end

      def write(data_stream)
        raise NotImplementedError
      end

      # Read from this repository. 
      # The data stream is yielded to the provided block. If the data
      # is unavailable then read should not yield and should return false.
      # Alternatively, the read method can also raise a Parcel::EmptyRepository
      # exception to inform the system that there is no data file to read in. This
      # is considered a successful operation.
      def read
        raise NotImplementedError
      end

      # Delete the parcel from the backend repository. The effect is immediate.
      def delete
        raise NotImplementedError
      end

    end
  end
end
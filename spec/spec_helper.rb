$: << File.join(File.dirname(__FILE__), "..", "lib")

require 'parcel'

class DummyStorage < Parcel::Storage::Base
end

class DummyInterface < Parcel::Interfaces::Base
end

Parcel.register_storage :dummy, DummyStorage
Parcel.register_interface :dummy, DummyInterface
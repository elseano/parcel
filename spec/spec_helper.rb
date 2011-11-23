$: << File.join(File.dirname(__FILE__), "..", "lib")

require 'parcel'

class DummyStorage < Parcel::Storage::Base

end

Parcel.register_storage :dummy, DummyStorage
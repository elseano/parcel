require File.join(File.dirname(__FILE__), "..", "..", "spec_helper")

describe Parcel::DSL do

	describe "#parcel" do

		it "should create the accessor" do
			temp_class = Class.new
			temp_class.has_parcel :test_parcel, :interface => :dummy

			temp_class.new.should respond_to(:test_parcel)
		end

		it "should return a parcel proxy" do
			temp_class = Class.new
			temp_class.has_parcel :interface => :dummy

			temp_class.new.parcel.should be_a(Parcel::Proxy)
		end

	end

end
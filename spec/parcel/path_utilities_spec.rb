require File.join(File.dirname(__FILE__), "..", "spec_helper")

describe Parcel::PathUtilities do
	subject { Parcel::PathUtilities }

	describe "#breakdown_integer" do

		it "should convert 1 to 0001/1" do
			subject.breakdown_integer(1).should == %w( 0001 1 )
		end

		it "should convert 123 to 0123/123" do
			subject.breakdown_integer(123).should == %w( 0123 123 )
		end

		it "should convert 123456 to 0012/3456/123456" do
			subject.breakdown_integer(123456).should == %w( 0012 3456 123456 )
		end

		it "should convert 0 to 0" do
			subject.breakdown_integer(0).should == %w( 0 )
		end

		it "should convert 1234567890" do
			subject.breakdown_integer(1234567890).should == %w( 0012 3456 7890 1234567890 )
		end

	end

end
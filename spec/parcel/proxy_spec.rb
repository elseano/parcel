require File.join(File.dirname(__FILE__), "..", "spec_helper")

describe Parcel::Proxy do

  let :backend_storage do
    mock("backend")
  end

  let :format_interface do 
    mock("format")
  end

  let :object do
    Object.new
  end

  subject do
    Parcel::Proxy.new(object, "output", :storage => backend_storage, :interface => format_interface)
  end

  describe "#stream" do
    it "should yield the stream from the format interface if prepared" do
      format_interface.should_receive(:stream).and_yield("raw data")
      backend_storage.stub!(:read)
      subject.prepare

      subject.stream do |file|
        file.should == "raw data"
      end
    end

    it "should not yield if not prepared" do
      format_interface.should_receive(:stream).never
      backend_storage.stub!(:read)

      subject.stream do |file|
        
      end
    end
  end

  describe "#save" do
    it "should save the interface stream to the backends if prepared" do
      backend_storage.stub!(:read)
      format_interface.should_receive(:stream).and_yield("raw data")
      backend_storage.should_receive(:write).with("raw data")

      subject.prepare
      subject.save
    end

    it "should not save anything if not prepared" do
      backend_storage.stub!(:read)
      format_interface.should_receive(:stream).never
      backend_storage.should_receive(:write).never

      subject.save
    end
  end

  describe "#delete" do
    it "should delete from the backends" do
      backend_storage.should_receive(:delete)
      subject.delete
    end
  end

  describe "#prepare" do
    it "should load in data" do
      backend_storage.should_receive(:read).and_yield("data")
      format_interface.should_receive(:import).with("data")

      subject.prepare
    end

    it "should only load in data once" do
      backend_storage.should_receive(:read).once.and_yield("data")
      format_interface.should_receive(:import).once.with("data")

      subject.prepare
      subject.prepare
    end
  end

  describe "other methods" do
    it "should be passed onto the format interface" do
      subject.should_receive(:prepare).once
      format_interface.should_receive(:read_file).with("some file").and_return("something")
      subject.read_file("some file").should == "something"
    end
  end

end
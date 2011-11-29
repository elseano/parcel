require File.join(File.dirname(__FILE__), "..", "..", "spec_helper")

describe Parcel::Storage::WarehouseStorage do

  let :object do
    mock("object", :warehoused? => false)
  end

  subject do
    Parcel::Storage::WarehouseStorage.new(object, "parcel", :fast_storage => :dummy, :warehouse_storage => :dummy).tap do |s|
      s.fast_storage.stub!(:read)
      s.fast_storage.stub!(:write)
      s.fast_storage.stub!(:delete)

      s.warehouse_storage.stub!(:read)
      s.warehouse_storage.stub!(:write)
      s.warehouse_storage.stub!(:delete)
    end
  end

  describe "#fast_storage" do

    it "should be the instance of the specified fast_storage engine" do
      subject.fast_storage.should be_a(DummyStorage)
    end

  end

  describe "#warehouse_storage" do
    it "should be the instance of the specified warehouse storage" do
      subject.warehouse_storage.should be_a(DummyStorage)
    end
  end

  describe "#write" do

    it "should write to the fast storage" do
      subject.fast_storage.should_receive(:write).once.with("data")
      subject.write("data")
    end

    it "should not write to the warehouse storage" do
      subject.warehouse_storage.should_receive(:write).never

      subject.write("data")
    end

  end

  describe "#read" do

    it "should yield to the fast storage" do
      subject.fast_storage.should_receive(:read).and_yield("stuff")
      subject.read do |data|
        data.should == "stuff"
      end
    end

    it "should read from fast_storage if not warehoused" do
      subject.fast_storage.should_receive(:read).and_yield("stuff")
      subject.warehouse_storage.should_receive(:read).never

      subject.read { nil }
    end

    it "should read from the warehouse storage if warehoused" do
      object.stub!(:warehoused?).and_return true
      subject.fast_storage.should_receive(:read).never
      subject.warehouse_storage.should_receive(:read).and_yield("warehouse")

      subject.read do |data|
        data.should == "warehouse"
      end
    end

  end

  describe "#delete" do

    it "should remove from the fast storage" do
      subject.fast_storage.should_receive(:delete).once

      subject.delete
    end

    it "should remove from the warehouse storage" do
      subject.warehouse_storage.should_receive(:delete).once

      subject.delete
    end

  end

  describe "#warehouse!" do

    it "should write the fast storage version to the warehouse and mark warehoused" do
      subject.fast_storage.should_receive(:read).and_yield("data")
      subject.fast_storage.should_receive(:delete)

      subject.warehouse_storage.should_receive(:write).with("data")

      expected_id = 101
      activerecord = mock("ActiveRecord::Base")

      object.stub!(:id).and_return(expected_id)
      activerecord.should_receive(:update_all).with("warehoused = true", "id = #{expected_id}")

      object.should_receive(:warehoused=).with(true)
      object.should_receive(:class).and_return(activerecord)

      subject.warehouse!
    end

  end

end
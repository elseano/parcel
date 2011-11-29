require 'activerecord'
require 'rubygems'
require 'zip/zip'
require 'sqlite3'

require File.join(File.dirname(__FILE__), "..", "spec_helper")

Parcel::Storage::LocalStorage.root = File.join(File.dirname(__FILE__), "..", "..", "tmp")

FileUtils.rm("specdb")
ActiveRecord::Base.establish_connection :adapter => "sqlite3", :database => "specdb"

class SetupDatabase < ActiveRecord::Migration
  def self.up
    create_table :test_table do
    end
  end
end

SetupDatabase.up

describe Parcel do

  describe "zip repository on the hard drive" do

    let :template do
      template = Class.new(ActiveRecord::Base)
      template.set_table_name "test_table"
      template.has_parcel :name => "parcel", :storage => :disk, :interface => :zip
      template
    end

    before(:each) do
      FileUtils.rm_rf(Parcel::Storage::LocalStorage.root)
    end
  
    it "should not create any repo if not accessed" do
      object = template.new
      object.save!

      expected_path = File.join(Parcel::Storage::LocalStorage.root, object.parcel_path, "parcel")

      File.exist?(expected_path).should be_false
    end

    it "should store in the correct path" do
      object = template.new
      object.parcel.should be_a(Parcel::Proxy)

      object.parcel.add_file("some_file", "This is file data which will be compressed")
      object.parcel.read_file("some_file").should == "This is file data which will be compressed"

      object.parcel.scratch.should be_a(Parcel::ScratchArea)
      object.parcel.scratch.exist?("extracted_some_file").should be_true

      object.save!

      expected_path = File.join(Parcel::Storage::LocalStorage.root, object.parcel_path, "parcel.zip")
      File.exist?(expected_path).should be_true
    end

    it "should not change an existing respository until saved" do
      FileUtils.rm_rf(Parcel::Storage::LocalStorage.root)

      object = template.new
      object.parcel.should_receive(:save).never
      object.parcel.add_file("some_file", "This is file data which will be compressed")
    end
  end
end
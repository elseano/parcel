require 'activerecord'
require 'rubygems'
require 'zip/zip'

require File.join(File.dirname(__FILE__), "..", "spec_helper")

Parcel::Storage::LocalStorage.root = File.join(File.dirname(__FILE__), "..", "..", "tmp")

describe Parcel do

	it "should store a zip repository to hard drive" do
		FileUtils.rm_rf(Parcel::Storage::LocalStorage.root)

		template = Class.new(ActiveRecord::Base)
		template.has_parcel :name => "parcel", :storage => :disk, :interface => :zip
		template.send(:define_method, :parcel_path) { "" }

		object = template.new
		object.parcel.should be_a(Parcel::Proxy)

		object.parcel.add_file("some_file", "This is file data which will be compressed")
		object.parcel.read_file("some_file").should == "This is file data which will be compressed"

		object.parcel.scratch.should be_a(Parcel::ScratchArea)
		object.parcel.scratch.exist?("extracted_some_file").should be_true

		object.parcel.save

		File.exist?(Parcel::Storage::LocalStorage.root).should be_true
	end

	it "should not change an existing respository until saved" do
		FileUtils.rm_rf(Parcel::Storage::LocalStorage.root)

		template = Class.new
		template.has_parcel :name => "parcel", :storage => :disk, :interface => :zip
		template.send(:define_method, :parcel_path) { "" }

		object = template.new
		object.parcel.add_file("some_file", "This is file data which will be compressed")

		File.exist?(Parcel::Storage::LocalStorage.root).should_not be_true
	end

end
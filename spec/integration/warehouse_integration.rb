require 'rubygems'
require 'aws/s3'
require 'zip/zip'

require File.join(File.dirname(__FILE__), "..", "spec_helper")

Parcel::Storage::LocalStorage.root = File.join(File.dirname(__FILE__), "..", "..", "tmp")

raise "AMAZON_ACCESS_KEY_ID needs to be set" if ENV["AMAZON_ACCESS_KEY_ID"].to_s == ""
raise "AMAZON_SECRET_ACCESS_KEY needs to be set" if ENV["AMAZON_SECRET_ACCESS_KEY"].to_s == ""
raise "PARCEL_BUCKET needs to be set" if ENV["PARCEL_BUCKET"].to_s == ""

AWS::S3::Base.establish_connection! :access_key_id => ENV["AMAZON_SECRET_ACCESS_KEY"], :secret_access_key => ENV["AMAZON_SECRET_ACCESS_KEY"]

# Use AMAZON_ACCESS_KEY_ID & AMAZON_SECRET_ACCESS_KEY

# AWS::S3::Base.establish_connection!(
# 	:access_key_id     => 'abc',
# 	:secret_access_key => '123'
# )


describe Parcel do

	describe "zip repository warehousing" do

		let :template do
			template = Class.new
			template.has_parcel :name => "parcel", :storage => :warehouse, :interface => :zip, :fast_storage => :disk, :warehouse_storage => :s3, :bucket => ENV["PARCEL_BUCKET"]
			template.send(:define_method, :parcel_path) { "" }
			template
		end

		before(:each) do
			FileUtils.rm_rf(Parcel::Storage::LocalStorage.root)
		end
	
		it "should write to fast storage" do
			object = template.new
			object.parcel.add_file "some_file", "This is the file data to add"
			object.parcel.save

			expected_path = File.join(Parcel::Storage::LocalStorage.root, object.parcel_path, "parcel")
			File.exist?(expected_path).should be_true
		end

		it "should not write to warehouse by default" do
			object = template.new
			object.parcel.add_file "some_file", "This is the file data to add"
			object.parcel.save

			expected_path = File.join(Parcel::Storage::LocalStorage.root, object.parcel_path, "parcel")
			File.exist?(expected_path).should be_true

			S3Object.exists?("parcel", ENV["PARCEL_BUCKET"]).should be_false
		end

		it "should warehouse the object when commanded" do
			object = template.new
			object.parcel.add_file "some_file", "This is the file data to add"
			object.parcel.save

			object.parcel.warehouse!

			expected_path = File.join(Parcel::Storage::LocalStorage.root, object.parcel_path, "parcel")
			File.exist?(expected_path).should be_false

			S3Object.exists?("parcel", ENV["PARCEL_BUCKET"]).should be_true
		end

	end

end


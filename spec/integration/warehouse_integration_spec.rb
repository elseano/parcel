require 'rubygems'
require 'aws'
require 'zip/zip'

require File.join(File.dirname(__FILE__), "..", "spec_helper")

raise "AMAZON_ACCESS_KEY_ID needs to be set" if ENV["AMAZON_ACCESS_KEY_ID"].to_s == ""
raise "AMAZON_SECRET_ACCESS_KEY needs to be set" if ENV["AMAZON_SECRET_ACCESS_KEY"].to_s == ""
raise "PARCEL_BUCKET needs to be set" if ENV["PARCEL_BUCKET"].to_s == ""

puts "Using AWS"
puts "Access Key: #{ENV['AMAZON_ACCESS_KEY_ID']}"
puts "Secret: #{ENV['AMAZON_SECRET_ACCESS_KEY']}"

Parcel.storage(:disk).root = File.join(File.dirname(__FILE__), "..", "..", "tmp")
Parcel.storage(:s3).setup ENV["AMAZON_ACCESS_KEY_ID"], ENV["AMAZON_SECRET_ACCESS_KEY"]

# Use AMAZON_ACCESS_KEY_ID & AMAZON_SECRET_ACCESS_KEY

# AWS::S3::Base.establish_connection!(
#   :access_key_id     => 'abc',
#   :secret_access_key => '123'
# )

s3_check = Aws::S3.new ENV["AMAZON_ACCESS_KEY_ID"], ENV["AMAZON_SECRET_ACCESS_KEY"]

describe Parcel do

  describe "zip repository warehousing" do

    let :template do
      template = Class.new
      template.has_parcel :name => "parcel", :storage => :warehouse, :interface => :zip, :fast_storage => :disk, :warehouse_storage => :s3, :bucket => ENV["PARCEL_BUCKET"]
      template.send(:define_method, :parcel_path) { "" }
      template.send(:define_method, :warehoused?) { @warehoused }
      template.send(:define_method, :warehoused=) { |value| @warehoused = value }

      def template.update_all(*args)
      end

      template
    end

    before(:each) do
      FileUtils.rm_rf(Parcel::Storage::LocalStorage.root)
      s3_check.bucket(ENV["PARCEL_BUCKET"]).key("parcel.zip").delete rescue nil
    end
  
    it "should write to fast storage" do
      object = template.new
      object.parcel.add_file "some_file", "This is the file data to add"
      object.parcel.save

      expected_path = File.join(Parcel::Storage::LocalStorage.root, object.parcel_path, "parcel.zip")
      File.exist?(expected_path).should be_true
    end

    it "should not write to warehouse by default" do
      object = template.new
      object.parcel.add_file "some_file", "This is the file data to add"
      object.parcel.save

      expected_path = File.join(Parcel::Storage::LocalStorage.root, object.parcel_path, "parcel.zip")
      File.exist?(expected_path).should be_true

      s3_check.bucket(ENV["PARCEL_BUCKET"]).key("parcel.zip").exists?.should be_false
    end

    it "should warehouse the object when commanded" do
      object = template.new
      object.parcel.add_file "some_file", "This is the file data to add"
      object.parcel.save

      object.parcel.warehouse!

      expected_path = File.join(Parcel::Storage::LocalStorage.root, object.parcel_path, "parcel.zip")
      File.exist?(expected_path).should be_false

      s3_check.bucket(ENV["PARCEL_BUCKET"]).key("parcel.zip").exists?.should be_true
    end

  end

end


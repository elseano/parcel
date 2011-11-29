require File.join(File.dirname(__FILE__), "..", "..", "spec_helper")

describe Parcel::Interfaces::ZipFileInterface do

  let :storage do
    mock("object")
  end

  describe "#contents" do
    it "should return an empty array if no zip file"
    it "should return the files of the imported zip file"
  end

  describe "#read_file" do
    it "should return nil if there is no zip file"
    it "should return nil if the file doesn't exist in the zip file"
    it "should find a file by it's exact name"
    it "should find a file by the * wildcard"
    it "should find a file by the ? wildcard"
    it "should return the scratch area file if extact match requested twice"
    it "should return the scratch area file if wildcard matched twice"
    it "should return new file if one wildcard matches differenct files between add_file calls"
  end

  describe "#add_file" do
    it "should add to the zip repository if it exists"
    it "should add a file if the zip repository doesn't exist"
    it "should add with subdirectories"
  end

end
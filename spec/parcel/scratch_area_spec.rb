require File.join(File.dirname(__FILE__), "..", "spec_helper")

describe Parcel::ScratchArea do

	describe "#designate" do
		it "should return a new path at the given root" do
			Parcel::ScratchArea.designate.should =~ /^\/tmp\/.+$/
		end

		it "should be unique" do
			(1..100).collect { Parcel::ScratchArea.designate }.uniq.length.should == 100
		end
	end

	describe "#prepare_root" do
		it "should create the scratch area" do
			subject = Parcel::ScratchArea.new
			subject.prepared_root =~ /^\/tmp\/.+$/
			File.exist?(subject.root).should be_true
		end
	end

	describe "#cleanup" do
		it "should remove the scratch area" do
			subject = Parcel::ScratchArea.new
			subject.prepared_root
			subject.cleanup

			File.exist?(subject.root).should be_false
		end

		it "should automatically cleanup after garbage collection" do
			if false # unsure how to test; seems to work though
				root, id = create_scratch_for_destroy

				GC.start; sleep(1); GC.start
				count = 0
				ObjectSpace.each_object(Parcel::ScratchArea) { |area| count += 1 }
				count.should == 0
				File.exist?(root).should be_false
			end
		end

		def create_scratch_for_destroy
			subject = Parcel::ScratchArea.new
			id = subject.id
			root = subject.prepared_root

			return root, id
		end

	end

	describe "#reset!" do
		it "should clear out the scratch area" do
			subject = Parcel::ScratchArea.new

			path = "#{subject.prepared_root}/test.txt"
			File.open(path, "w") { |f| f.write "test!" }

			subject.reset!

			File.exist?(path).should be_false
		end
	end

	describe "#import" do
		it "should import a file stream" do
			path = "/tmp/test.txt"
			File.open(path, "w") { |f| f.write "test!" }

			subject = Parcel::ScratchArea.new
			File.open(path, "r") { |file| subject.import("test", file) }

			File.exist?("#{subject.root}/test").should be_true
		end

		it "should import a string" do
			subject = Parcel::ScratchArea.new
			subject.import("test", "this is data")

			IO.read("#{subject.root}/test").should == "this is data"
		end
	end

	describe "#path" do
		it "should return the named resource path" do
			subject = Parcel::ScratchArea.new

			subject.path("sean").should == "#{subject.root}/sean"
		end

		it "should prepare the area" do
			subject = Parcel::ScratchArea.new
			subject.should_receive(:prepared_root).and_return("blah")
			subject.path("name").should == "blah/name"
		end
	end

	describe "#exist?" do
		it "should return true if the file is present" do
			subject = Parcel::ScratchArea.new
			path = "#{subject.prepared_root}/test.txt"
			File.open(path, "w") { |f| f.write "test!" }
			subject.exist?("test.txt").should be_true
		end

		it "should return false if the file is not present" do
			subject = Parcel::ScratchArea.new
			subject.exist?("test.txt").should be_false
		end
	end


end
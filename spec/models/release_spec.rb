require 'spec_helper'

require 'tempfile'

describe Release do

  let(:release) { Release.new }
  
  context "named :test" do

    subject { Release.new :name => "test" }

    its(:file) { should == "/tmp/test.tar" }

  end

  context "after initialize" do
    
    its(:status_updated_at) { should_not be_nil }

  end

  describe ".current" do

    let(:release) { Release.new :name => "test" }
    
    it "should find Release with :installed status" do
      Release.should_receive(:find_by_status).with("installed").and_return(release)
      Release.current.should == release
    end

  end

  describe ".latest" do

    let(:last_release) { Release.new :name => "test" }
    
    it "should use last Release" do
      Release.stub :last => last_release
      Release.latest.should == last_release
    end

    it "should return nil when current release is the last one" do
      Release.stub :current => last_release, :last => last_release
      Release.latest.should be_nil
    end

    it "should return nil when no release is available" do
      Release.stub :last => nil
      Release.latest.should be_nil
    end

  end

  describe ".newer?" do
    
    it "should be true when other release is nil" do
      release.should be_newer(nil)
    end

    it "should be true when name is greather than the other one" do
      release.name = "version-2"
      release.should be_newer(stub(:name => "version-1"))
    end

  end

  describe ".check_latest" do

    let(:latest) { Release.new :name => "version-2" }

    before(:each) do
      Release.stub :latest_url => "latest_url"
      Release::Loader.stub :release_at => latest
    end
    
    it "should save release at latest_url" do
      Release::Loader.should_receive(:save_release_at).with("latest_url").and_return(latest)
      Release.check_latest
    end

    it "should set release status to :available" do
      Release.check_latest
      latest.status.should be_available
    end

    it "should not save the latest release if not newer the last one" do
      Release.stub :last => Release.new
      latest.should_receive(:newer?).with(Release.last).and_return(false)
      Release.check_latest.should be_false
    end
                         
  end

  describe ".check_current" do

    let(:current) { Release.new :name => "current" }

    before(:each) do
      Release.stub :current_url => "current_url"
      Release::Loader.stub :release_at => current
    end

    it "should save release at current_url" do
      Release::Loader.should_receive(:save_release_at).with("current_url").and_return(current)
      Release.check_current
    end

    it "should set release status to :installed" do
      Release.check_current
      current.status.should be_installed
    end

    it "should not create current release if already exist" do
      Release.create! :name => current.name, :status => :installed
      Release.check_current.should be_false
    end

  end

  describe "human_name" do

    let(:release) { Release.new }
    
    it "should contain space instead of underscore" do
      release.name = "dummy_name"
      release.human_name.should match(" name")
    end

    it "should capitalize name" do
      release.name = "dummy name"
      release.human_name.should == "Dummy name"
    end

    it "should capitalize box" do
      release.name = "dummybox"
      release.human_name.should == "DummyBox"
    end

    it "should transform 'streambox_20100414-1224' into 'StreamBox 20100414-1224'" do
      release.name = "streambox_20100414-1224"
      release.human_name.should == 'StreamBox 20100414-1224'
    end

  end

  describe "download!" do

    let(:release) { Release.new :name => "test", :url => "public/updates/streambox-update-20100421-0846.tar" }

    before(:each) do
      FileUtils.rm_f(release.file)
      release.stub :valid_checksum? => true
    end
    
    it "should 'copy' url content into file" do
      release.download!
      FileUtils.compare_file(release.file, release.url)
    end

    it "should raise an error if checksum is invalid" do
      release.stub :valid_checksum? => false
      lambda { release.download! }.should raise_error
    end

  end

  describe "start_download" do
    
    it "should send_later download! method" do
      release.should_receive(:send_later).with(:download!)
      release.start_download
    end

    it "should change status to download_pending" do
      release.stub! :send_later
      lambda {
        release.start_download
      }.should change(release, :status).to("download_pending")
    end

    it "should return if release is already downloaded" do
      release.status = :downloaded
      release.should_not_receive(:send_later).with(:download!)
      release.start_download
    end

  end

  describe "valid_checksum?" do

    let(:release) { Release.new :name => "test", :url => "public/updates/streambox-update-20100421-0846.tar" }

    before(:each) do
      release.stub :file => release.url
    end

    it "should return true if checksum is SHA256 digest of downloaded file" do
      release.checksum = "9eeb495a5b273c7dd88aa8dd741df8ecf10b5a34c422b0fe6b7a1b053a518369"
      release.should be_valid_checksum
    end

    it "should return false if checksum is not the SHA256 digest of downloaded file" do
      release.checksum = "dummy"
      release.should_not be_valid_checksum
    end

    it "should return false if checksum is nil" do
      release.checksum = nil
      release.should_not be_valid_checksum
    end

    it "should return false if download file isn't found" do
      release.stub!(:file_checksum)
      release.should_not be_valid_checksum
    end

  end

  describe "#install" do

    before(:each) do
      release.stub!(:tempfile_with_attributes).and_yield("/path/to/tempfile")
    end
    
    it "should execute install command with release file and temp file (with attributes) in argument" do
      release.stub :install_command => "/usr/bin/dummy", :file => "/tmp/test.tar"
      release.should_receive(:system).with("/usr/bin/dummy /tmp/test.tar /path/to/tempfile").and_return(true)
      release.install
    end

    context "when install command fails" do
      
      before(:each) do
        release.stub :system => false
      end

      it "should return false" do
        release.install.should be_false
      end

    end

    context "when install command is successfull" do

      before(:each) do
        release.stub :system => true
      end

      it "should change current release" do
        Release.should_receive(:change_current).with(release)
        release.install
      end
                                                    
    end

  end

  describe "#tempfile_with_attribute" do
    
    let(:tempfile) { stub :path => "/path/to/tempfile", :puts => true }

    before(:each) do
      Tempfile.stub!(:open).and_yield(tempfile)
    end

    it "should open a Tempfile" do
      Tempfile.should_receive(:open).and_yield(tempfile)
      release.tempfile_with_attributes { |f| }
    end

    it "should write attributes in yaml into tempfile" do
      tempfile.should_receive(:puts).with(release.attributes.to_yaml)
      release.tempfile_with_attributes { |f| }
    end

    it "should yield given block with tempfile path" do
      given_path = nil
      release.tempfile_with_attributes do |path| 
        given_path = path
      end
      given_path.should == tempfile.path
    end

  end
  
end

describe Release::Loader do
  
  describe "#attributes" do
    
    it "should load attributes found in url" do
      Tempfile.open("release-loader") do |file|
        file.puts "dummy: true"
        file.close

        Release::Loader.new(file.path).attributes.should == { "dummy" => true }
      end
    end

  end

  describe "#supported_attributes" do

    let(:loader) { Release::Loader.new("dummy") }
    
    it "should remove unsupported attributes from attributes" do
      loader.stub :attributes => { :checksum => "present", :dummy => true }
      loader.supported_attributes.should == { :checksum => "present" }
    end

  end

  describe "#release" do

    let(:loader) { Release::Loader.new("dummy") }
    
    it "should create a new Release with supported_attributes" do
      loader.stub :supported_attributes => { :checksum => "dummy" }
      loader.release.checksum.should == "dummy"
    end

  end

  describe ".release_at" do

    let(:url) { "dummy://url" }
    let(:loaded_release) { Release.new }

    it "should create a new Loader and load release" do
      Release::Loader.should_receive(:new).with(url).and_return(stub(:release => loaded_release))
      Release::Loader.release_at(url).should == loaded_release
    end

  end

  describe "save_release_at" do

    let(:url) { "dummy://url" }
    let(:loaded_release) { Release.new }

    before(:each) do
      Release::Loader.stub :release_at => loaded_release
    end
    
    it "should used Release loaded with release_at" do
      Release::Loader.should_receive(:release_at).with(url).and_return(loaded_release)
      Release::Loader.save_release_at(url)
    end

    it "should save loaded release when no block is given" do
      loaded_release.should_receive(:save)
      Release::Loader.save_release_at(url)
    end

    it "should yield loaded release when block is given" do
      given_release = nil
      Release::Loader.save_release_at(url) do |release|
        given_release = release
      end
      given_release.should == loaded_release
    end

    it "should save loaded release when given block returns true" do
      loaded_release.should_receive(:save)
      Release::Loader.save_release_at(url) { |release| true }
    end

    it "should not save loaded release if given block returns false" do
      loaded_release.should_not_receive(:save)
      Release::Loader.save_release_at(url) { |release| false }
    end

  end
                         
end

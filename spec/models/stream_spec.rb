require 'spec_helper'

describe Stream do

  let(:stream) { Stream.new }

  before(:each) do
    @stream = Stream.new

    @puppet_configuration = PuppetConfiguration.new
    PuppetConfiguration.stub!(:load).and_return(@puppet_configuration)
  end

  after(:each) do
    PuppetConfiguration.destroy
  end

  it { should validate_presence_of :name }

  it { should validate_presence_of :server }
  it { should validate_presence_of :port }
  it { should validate_presence_of :mount_point }
  it { should validate_presence_of :password }

  it "should remove initial / in mount point" do
    @stream.mount_point = "/dummy"
    @stream.mount_point.should == "dummy"
  end

  it "should validate server as a host" do
    @stream.server = "localhost"
    @stream.stub!(:validate_host).and_return(false)
    @stream.should have(1).error_on(:server)
  end

  it "should strip attributes before validation" do
    @stream.password = " dummy "
    @stream.valid?
    @stream.password.should == "dummy"
  end

  it "should use Stream.default_attributes for a new Stream" do
    Stream.stub :default_attributes => { :server => "dummy" }
    Stream.new.server.should == "dummy"
  end

  it "should use vorbis format for a new Stream" do
    Stream.new.format.should == :vorbis
  end

  it "should use quality 4 for a new Stream" do
    Stream.new.quality.should == 4
  end

  it "should enable a new Stream" do
    Stream.new.should be_enabled
  end

  describe "format" do

    it { should validate_presence_of :format }
    
    it "should support :vorbis, :mp3 and :aac" do
      @stream.should allow_values_for :format, :vorbis, :mp3, :aac
      @stream.should_not allow_values_for :dummy
    end

    it "should transforme the given format into a symbol" do
      @stream.format = "vorbis"
      @stream.format.should == :vorbis
    end

  end

  describe "quality" do

    it { should validate_presence_of :quality }

    it "should accept quality between 0 and 10" do
      @stream.should allow_values_for :quality, *(0..10).to_a
      @stream.should_not allow_values_for :quality, -1, 11
    end

    it "should transforme the given quality into an integer" do
      @stream.quality = "5"
      @stream.quality.should == 5
    end

  end

  describe "can_create?" do
    
    it "should be true when Stream count less than Stream.maximum_count" do
      Stream.stub!(:maximum_count).and_return(4)
      Stream.stub!(:count).and_return(3)
      Stream.can_create?.should be_true
    end

    it "should be false when Stream count equals Stream.maximum_count" do
      Stream.stub!(:maximum_count).and_return(3)
      Stream.stub!(:count).and_return(3)
      Stream.can_create?.should be_false
    end

  end

  describe "url" do
    
    it "should create a pseudo url with server, port and path" do
      @stream.stub!(:server).and_return("server")
      @stream.stub!(:port).and_return("port")
      @stream.stub!(:mount_point).and_return("mount_point")

      @stream.url.should == "server:port/mount_point"
    end

  end

  describe "path" do
    
    it "should return /mount_point if it doesn't include a starting /" do
      @stream.mount_point = "mount_point"
      @stream.path.should == "/mount_point"
    end

    it "should return mount_point if it includes a starting /" do
      @stream.mount_point = "/mount_point"
      @stream.path.should == "/mount_point"
    end

  end

  describe "default_attributes" do
    
    describe "port" do

      subject { Stream.default_attributes[:port] }

      it "should be 8000 if no other stream exists" do
        Stream.stub! :last
        should == 8000
      end

      it "should use the last stream port" do
        Stream.stub :last => Stream.new(:port => 80)
        should == 80
      end
      
    end

    def self.it_should_use_last_stream(attribute)
      describe attribute.to_s do

        subject { Stream.default_attributes[attribute] }
        
        it "should be nil if no other stream exists" do
          Stream.stub!(:last)
          should be_nil
        end

        it "should use the last stream #{attribute}" do
          Stream.stub :last => Stream.new(attribute => "dummy")
          should == "dummy"
        end

      end
    end

    it_should_use_last_stream :server
    it_should_use_last_stream :description
    it_should_use_last_stream :genre
    it_should_use_last_stream :related_url

  end

  describe "to_param" do
    
    it "should return stream id as string" do
      @stream.id = 1
      @stream.to_param.should == "1"
    end
    
  end

  describe "presenter" do

    it "should return a StreamPresenter" do
      StreamPresenter.should_receive(:new).with(@stream).and_return(presenter = mock(StreamPresenter))
      @stream.presenter.should == presenter
    end
    
  end

  describe "save" do
    
    it "should assign an identifier to new record" do
      @stream.stub!(:valid?).and_return(true)
      @stream.save
      @stream.id.should_not be_nil
    end

    it "should modify stream_<id> configuration" do
      @puppet_configuration["stream_1_name"] = "old name"
      @stream = Stream.find(1)
      @stream.stub!(:valid?).and_return(true)
      @stream.name = "new name"
      @stream.save
      @puppet_configuration["stream_1_name"].should == "new name"
    end

    describe "when stream is invalid" do

      before(:each) do
        @stream.stub!(:valid?).and_return(false)      
      end

      it "should return false" do
        @stream.save.should be_false
      end

      it "should not modify PuppetConfiguration" do
        @stream.save.should be_false
        @puppet_configuration.should be_empty
      end

      it "should return true if save is force" do
        @stream.save(true).should be_true
      end
      
    end
    
  end

  describe "update_attributes" do
    
    it "should save Stream" do
      @stream.should_receive(:save)
      @stream.update_attributes :name => "test"
    end

  end

  describe "destroy" do
    
    it "should modify stream_<id> configuration" do
      @puppet_configuration["stream_1_name"] = "old name"
      Stream.find(1).destroy
      @puppet_configuration["stream_1_name"].should be_nil
    end

    it "should reorder other streams" do
      @puppet_configuration["stream_1_name"] = "removed"
      @puppet_configuration["stream_2_name"] = "kept"
      Stream.find(1).destroy
      @puppet_configuration["stream_1_name"].should == "kept"
      @puppet_configuration["stream_2_name"].should be_nil
    end

  end

  describe "class method" do

    describe "all" do
     
      it "should load 4 available streams" do
        5.times do |n|
          @puppet_configuration["stream_#{n+1}_name"] = "Stream #{n}"
        end
        Stream.all.count.should == 4
      end

      it "should load attributes defined by stream_<n>_<attribute> keys" do
        4.times do |n|
          @puppet_configuration["stream_#{n+1}_name"] = "Stream #{n}"
        end
        Stream.all.collect(&:name).should == Array.new(4) { |n| "Stream #{n}" }
      end

      it "should assign stream identifiers" do
        4.times do |n|
          @puppet_configuration["stream_#{n+1}_name"] = "Stream #{n}"
        end
        Stream.all.collect(&:id).should == (1..4).to_a
      end

      it "should load enabled attribute defined by stream_<n>_enabled keys" do
        4.times do |n|
          @puppet_configuration["stream_#{n+1}_enabled"] = n.odd?
        end
        Stream.all.collect(&:enabled).should == [ false, true, false, true ]
      end

    end

    describe "find" do

      it "should return the Stream with the given identifier" do
        3.times do |n|
          @puppet_configuration["stream_#{n+1}_name"] = "Stream #{n+1}"
        end
        Stream.find(2).name.should == "Stream 2"
      end

      it "should support identifier as string" do
        @puppet_configuration["stream_1_name"] = "Stream 1"
        Stream.find("1").should_not be_nil
      end

      it "should return nil if id isn't found'" do
        Stream.find(1).should be_nil
      end
      
    end

    describe "count" do
      
      it "should return the size of Stream.all" do
        Stream.stub!(:all).and_return([1,2])
        Stream.count.should == 2
      end

    end

  end

  describe "enabled=" do
    
    it "should enable stream with 1" do
      stream.enabled=1
      stream.should be_enabled
    end

    it "should enable stream with true" do
      stream.enabled=true
      stream.should be_enabled
    end

    it "should enable stream with 'true'" do
      stream.enabled='true'
      stream.should be_enabled
    end

    it "should enable stream with '1'" do
      stream.enabled='1'
      stream.should be_enabled
    end

    it "should disable stream with anything else" do
      stream.enabled = mock
      stream.should be_disabled
    end

  end

end

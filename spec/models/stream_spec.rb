require 'spec_helper'

describe Stream do

  before(:each) do
    @stream = Stream.new

    @puppet_configuration = PuppetConfiguration.new
    PuppetConfiguration.stub!(:load).and_return(@puppet_configuration)
  end

  after(:each) do
    PuppetConfiguration.destroy
  end

  it { should validate_presence_of :server }
  it { should validate_presence_of :port }
  it { should validate_presence_of :mount_point }
  it { should validate_presence_of :password }

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

  end
end

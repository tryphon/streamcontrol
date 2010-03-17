require 'spec_helper'

describe StreamsController do

  before(:each) do
    @stream = Stream.new
  end

  describe "GET 'show'" do
    it "should be successful" do
      get 'show'
      response.should be_success
    end

    it "should render show view" do
      get 'show'
      response.should render_template("show")
    end

    it "should define @stream by load a new instance" do
      Stream.should_receive(:load).and_return(@stream)
      get 'show'
      assigns[:stream].should == @stream
    end

  end

  describe "GET 'edit'" do
    it "should be successful" do
      get 'edit'
      response.should be_success
    end

    it "should render edit view" do
      get 'edit'
      response.should render_template("edit")
    end

    it "should define @stream by load a new instance" do
      Stream.should_receive(:load).and_return(@stream)
      get 'edit'
      assigns[:stream].should == @stream
    end

  end

  describe "PUT 'update'" do

    before(:each) do
      @params = { "dummy" => true }
      Stream.stub!(:new).and_return(@stream)
    end

    it "should create a Stream instance with form attributes" do
      Stream.should_receive(:new).with(@params).and_return(@stream)
      post 'update', :stream => @params
    end

    it "should save the Stream instance" do
      @stream.should_receive(:save).and_return(true)
      post 'update'
    end

    describe "when stream is successfully saved" do

      before(:each) do
        @stream.stub!(:save).and_return(true)
      end
      
      it "should redirect to stream path" do
        post 'update'
        response.should redirect_to(stream_path)
      end

      it "should define a flash notice" do
        post 'update'
        flash.should have_key(:success)
      end

    end

    describe "when stream isn't saved" do

      before(:each) do
        @stream.stub!(:save).and_return(false)
      end
      
      it "should redirect to edit action" do
        post 'update'
        response.should render_template("edit")
      end

      it "should define a flash failure" do
        post 'update'
        flash.should have_key(:failure)
      end

    end

  end

end

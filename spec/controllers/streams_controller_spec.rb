require 'spec_helper'

describe StreamsController do

  describe "GET 'index'" do

    let(:streams) { Array.new(3) { double Stream } }

    it "should define @streams with Stream.all" do
      Stream.should_receive(:all).and_return(streams)
      get 'index'
      assigns[:streams].should == streams
    end

  end

  describe "PUT 'toggle'" do

    let(:stream) { Stream.new }

    before(:each) do
      Stream.stub :find => stream
      request.env["HTTP_REFERER"] = "http://test/dummy"
    end

    context "when stream is enabled" do
      it "should set #enabled to false" do
        pending

        stream.enabled = true
        put 'toggle', :id => 1
        stream.should be_disabled
      end
    end

    context "when stream is disabled" do
      it "should set #enabled to true" do
        pending

        stream.enabled = false
        put 'toggle', :id => 1
        stream.should be_enabled
      end
    end

  end

end

require 'spec_helper'

describe StreamsController do

  describe "GET 'index'" do

    before(:each) do
      @streams = Array.new(3) { mock Stream }
    end

    it "should define @streams with Stream.all" do
      Stream.should_receive(:all).and_return(@streams)
      get 'index'
      assigns[:streams].should == @streams
    end

  end

end

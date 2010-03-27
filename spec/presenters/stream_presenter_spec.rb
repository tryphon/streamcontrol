require 'spec_helper'

describe StreamPresenter do

  before(:each) do
    @stream = mock(Stream)
    @stream_presenter = StreamPresenter.new(@stream)
  end

  describe "format" do
    
    it "should find the associated StreamFormatPresenter" do
      @stream.stub!(:format).and_return("dummy")
      StreamFormatPresenter.should_receive(:find).with("dummy").and_return(format_presenter = mock(StreamFormatPresenter))
      @stream_presenter.format.should == format_presenter
    end

  end


end

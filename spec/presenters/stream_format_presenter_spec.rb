require 'spec_helper'

describe StreamFormatPresenter do

  before(:each) do
    @format_presenter = StreamFormatPresenter.new(:dummy, "Dummy", "Dummy_Page")
  end

  describe "wikipedia_url" do
    
    it "should create the wikipedia url with current locale and wikipedia_page" do
      I18n.stub!(:locale).and_return("en")
      @format_presenter.wikipedia_url.should == "http://en.wikipedia.org/wiki/Dummy_Page"
    end

  end

  describe "class method find" do
    
    it "should return the StreamFormatPresenter associated to the given format" do
      StreamFormatPresenter.stub!(:all).and_return([@format_presenter])
      StreamFormatPresenter.find(:dummy).should == @format_presenter
    end

    it "should return nil when the StreamFormatPresenter isn't found" do
      StreamFormatPresenter.find(:dummy).should be_nil
    end

  end

  describe "class method all" do
    
    it "should return StreamFormatPresenters for :vorbis, :mp3 and :aac" do
      StreamFormatPresenter.all.collect(&:format).should == [ :vorbis, :mp3, :aac ]
    end

  end

end

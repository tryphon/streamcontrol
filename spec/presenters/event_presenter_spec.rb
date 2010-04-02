require 'spec_helper'

describe EventPresenter, :type => :helper do

  before(:each) do
    @presenter = EventPresenter.new(@event = Event.new)
  end

  it "should provide an image tag using /images/error.png for Event with severity error" do
    @event.severity = :error
    @presenter.severity_image_tag.should have_tag("img[src^=/images/error.png]")
  end

  it "should provide an image tag using /images/info.png for Event with severity info" do
    @event.severity = :info
    @presenter.severity_image_tag.should have_tag("img[src^=/images/info.png]")
  end

  describe "user_message" do
    
    it "should use the translation of events.message.<event.message>" do
      @event.message = :dummy
      I18n.should_receive(:translate).with("events.message.dummy", anything).and_return("Dummy")
      @presenter.user_message.should == "Dummy"
    end

    it "should use default_message as default translation" do
      @presenter.stub!(:default_message).and_return("default message")
      I18n.should_receive(:translate).with(anything, :default => "default message")
      @presenter.user_message
    end

  end

  describe "default_message" do
    
    it "should be an humanized version of Event#message" do
      @event.message = "dummy_with_spaces"
      @presenter.default_message.should == "Dummy with spaces"
    end

  end

end

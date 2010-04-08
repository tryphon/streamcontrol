require 'spec_helper'

describe "/events/index" do

  before(:each) do
    assigns[:events] = @events = Array.new(3) { |n| Event.create! :severity => :info, :message => "dummy" }
    template.stub!(:will_paginate)
  end

  it "should display event created_at" do
    @events.first.stub!(:created_at).and_return(Time.parse("1 april 2010 10:00:15"))
    render 'events/index'
    response.should have_tag("td", "01 avril 2010 10:00:15")
  end

  it "should display the image associated to the severity" do
    @events.first.stub!(:severity).and_return(:error)
    render 'events/index'
    response.should have_tag("img[src^=/images/error.png]")
  end

  it "should display the user message" do
    @events.first.presenter.stub!(:user_message).and_return("Dummy Message")
    render 'events/index'
    response.should have_tag("td", "Dummy Message")
  end

  it "should display a link to the associated stream" do
    @events.first.presenter.should_receive(:stream_link).with(template).and_return('<a id="link"/>')
    render 'events/index'
    response.should have_tag("a#link")
  end

  it "should paginate the events" do
    template.should_receive(:will_paginate).and_return('<div id="paginate"/>')
    render
    response.should have_tag("#paginate")
  end
  
end

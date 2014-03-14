require 'spec_helper'

describe "/events/index.html.erb" do

  let!(:events) do
    assign :events, EventDecorator.decorate_collection(Array.new(3) { |n| Event.create! :severity => :info, :message => "dummy" }.paginate)
  end

  it "should display event created_at" do
    events.first.stub :created_at => Time.parse("1 april 2010 10:00:15")
    render
    response.should have_selector("td", :text => "April 01 2010 10:00:15")
  end

  it "should display the image associated to the severity" do
    events.first.stub :severity => :error
    render
    response.should have_selector("img[src^='/assets/error.png']")
  end

  it "should display the user message" do
    events.first.stub :user_message => "Dummy Message"
    render
    response.should have_selector("td", :text => "Dummy Message")
  end

  it "should display a link to the associated stream" do
    events.first.stub :stream_link => '<a id="link"/>'.html_safe
    render
    response.should have_selector("a#link")
  end

  it "should paginate the events" do
    view.stub :will_paginate => '<div id="paginate"/>'.html_safe
    render
    response.should have_selector("#paginate")
  end

end

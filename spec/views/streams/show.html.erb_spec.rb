require 'spec_helper'

describe "/streams/show" do

  let(:stream) { Stream.new :id => 1 }

  before(:each) do
    assigns[:stream] = stream
  end

  it "should include stream name in title" do
    stream.name = "Dummy"
    render
    response.should have_tag("h1", /Dummy/)
  end

  it "should display format name (via StreamPresenter#format)" do
    stream.presenter.stub :format => mock(StreamFormatPresenter, :name => "dummy format")
    render
    response.should have_tag("p", /dummy format/)
  end

  def self.it_should_display_when_blank(attribute)
    it "should not display #{attribute} when blank" do
      Stream.should_not_receive(:human_attribute_name).with(attribute)
      render
    end
  end

  it_should_display_when_blank :description
  it_should_display_when_blank :genre
  it_should_display_when_blank :related_url

  it "should display a message when all description attributes are blank" do
    stream.presenter.stub :blank_description_attributes? => true
    template.stub :t => "dummy"
    template.should_receive(:t).with(".no_description_attributes").and_return("message when no description attributes")
    render
    response.should have_tag("p", /message when no description attributes/)
  end

  it "should display a link to edit the stream" do
    render
    response.should have_link_to(edit_stream_path(stream))
  end

  it "should display a link to destroy the stream" do
    render
    response.should have_link_to(stream_path(stream), :class => "destroy")
  end

  it "should display a link to enable the stream when disabled" do
    stream.enabled = false
    render
    response.should have_link_to(toggle_stream_path(stream), :class => "enable")
  end

  it "should display a link to disable the stream when enable" do
    stream.enabled = true
    render
    response.should have_link_to(toggle_stream_path(stream), :class => "disable")
  end

end

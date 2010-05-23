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

end

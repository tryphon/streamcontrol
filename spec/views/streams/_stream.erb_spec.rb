require 'spec_helper'

describe "/streams/_stream.erb" do

  let(:stream) { Stream.new :id => 1 }

  def render
    super :locals => {:stream => stream}
  end

  it "should display stream description when not blank" do
    stream.description = "dummy"
    render
    response.should have_tag("p", "Description: dummy")
  end

  it "should not display stream description when blank" do
    stream.description = ""
    render
    response.should_not have_tag("p", /Description/)
  end

  it "should display stream url" do
    stream.stub :url => "dummy"
    render
    response.should have_tag("p", "URL: dummy")
  end

end

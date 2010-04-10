require 'spec_helper'

describe "/streams/index" do

  before(:each) do
    assigns[:streams] = @streams = Array.new(3) { |n| Stream.new(:id => n+1) }
  end

  it "should display a link to create a new stream" do
    render
    response.should have_link_to(new_stream_path)
  end

  it "should not display a link to create a new stream when Stream.can_create? is false" do
    Stream.stub!(:can_create?).and_return(false)
    render
    response.should_not have_tag("a[href=?]", new_stream_path)
  end

  it "should render the inline help partial" do
    template.should_receive(:render).with(:partial => 'index_inline_help').and_return("inline_help")
    render
    response.should have_tag("div[class=inline_help]","inline_help")
  end

end

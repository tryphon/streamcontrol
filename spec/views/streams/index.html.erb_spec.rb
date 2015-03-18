require 'spec_helper'

describe "/streams/index.html.erb" do

  let!(:streams) { assign :streams, Array.new(3) { |n| Stream.new(:id => n+1) } }

  before do
    Stream.stub 'can_create?' => true
  end

  it "should display a link to create a new stream" do
    render
    response.should have_link('Add a new stream', :href => new_stream_path)
  end

  it "should not display a link to create a new stream when Stream.can_create? is false" do
    Stream.stub :can_create? => false
    render
    response.should_not have_link('Add a new stream')
  end

  it "should render the inline help partial" do
    stub_template "_index_inline_help" => "inline_help"
    render
    response.should have_selector("div[class=inline_help]", :text => "inline_help")
  end

end

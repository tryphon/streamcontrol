require 'spec_helper'

describe "/streams/edit" do

  before(:each) do
    assigns[:stream] = @stream = Stream.new(:id => 1)
  end

  it "should provide a back link to the stream path" do
    render
    response.should have_tag("a[href=?]", stream_path(@stream))
  end

end

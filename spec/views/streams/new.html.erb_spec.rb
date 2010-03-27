require 'spec_helper'

describe "/streams/new" do

  before(:each) do
    assigns[:stream] = @stream = Stream.new
  end

  it "should provide a back link to the streams path" do
    render
    response.should have_tag("a[href=?]", streams_path)
  end

end

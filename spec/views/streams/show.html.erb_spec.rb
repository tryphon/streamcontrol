require 'spec_helper'

describe "/streams/show" do

  before(:each) do
    assigns[:stream] = @stream = Stream.new
    @stream.id = 1
  end

  it "should include stream name in title" do
    @stream.name = "Dummy"
    render
    response.should have_tag("h1", /Dummy/)
  end

  it "should display format name (via StreamPresenter#format)" do
    @stream.presenter.stub!(:format).and_return(mock(StreamFormatPresenter, :name => "dummy format"))
    render
    response.should have_tag("p", /dummy format/)
  end

end

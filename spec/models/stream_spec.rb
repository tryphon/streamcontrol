require 'spec_helper'

describe Stream do

  before(:each) do
    @stream = Stream.new
  end

  it { should validate_presence_of :server }
  it { should validate_presence_of :port }
  it { should validate_presence_of :mount_point }
  it { should validate_presence_of :password }

  it "should validate server as a host" do
    @stream.server = "localhost"
    @stream.stub!(:validate_host).and_return(false)
    @stream.should have(1).error_on(:server)
  end

end

require 'spec_helper'

describe Stream do
  before(:each) do
    @stream = Stream.new
  end

  it "should not allow a blank server" do
    @stream.should_not allow_values_for(:server, "") 
  end

end

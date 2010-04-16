require 'spec_helper'

describe MonitoringsController do

  before(:each) do
    Monitoring.stub :find => Monitoring.new(:dummy)
  end

  describe "GET 'show'" do
    it "should be successful" do
      get 'show', :id => "dummy"
      response.should be_success
    end
  end

end

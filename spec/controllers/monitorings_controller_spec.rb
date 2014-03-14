require 'spec_helper'

describe MonitoringsController do

  before(:each) do
    Monitoring.stub :find => Monitoring.new(:cpu)
  end

  describe "GET 'show'" do
    it "should be successful" do
      get 'show', :id => "cpu", :format => :png
      response.should be_success
    end
  end

end

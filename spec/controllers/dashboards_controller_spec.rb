require 'spec_helper'

describe DashboardsController do

  before do
    Event.stub latest: []
  end

  describe "GET 'show'" do
    it "should be successful" do
      get 'show'
      response.should be_success
    end

    it "should assign decorated events" do
      get 'show'
      assigns(:events).should be_decorated
    end
  end
end

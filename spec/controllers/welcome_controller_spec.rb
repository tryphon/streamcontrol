require 'spec_helper'

describe WelcomeController do
  describe "GET 'index'" do
    it "should redirect to the Streams configuration" do
      get 'index'
      response.should redirect_to(streams_path)
    end
  end
end

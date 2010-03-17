require 'spec_helper'

describe WelcomeController do
  describe "GET 'index'" do
    it "should redirect to the Stream configuration" do
      get 'index'
      response.should redirect_to(stream_path)
    end
  end
end

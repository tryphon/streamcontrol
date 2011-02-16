require 'spec_helper'

describe MetadataController do

  describe "POST /create" do
    
    it "should redirect to #metadata/new" do
      post :create, :metadata => {:song => "dummy" }
      response.should redirect_to(new_metadata_path)
    end

    it "should response to a json post" do
      post :create, :metadata => {:song => "dummy" }, :format => :json
      response.should be_success
    end

  end

end

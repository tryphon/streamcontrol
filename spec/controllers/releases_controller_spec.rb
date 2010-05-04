require 'spec_helper'

describe ReleasesController do
  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end

    it "should assign @current with Release.current" do
      Release.stub :current => stub('current')
      get 'index'
      assigns[:current].should == Release.current
    end

    it "should assign @latest with Release.latest" do
      Release.stub :latest => stub('latest')
      get 'index'
      assigns[:latest].should == Release.latest
    end
  end

  describe "GET 'download'" do

    let(:release) { stub_model(Release) }

    before(:each) do
      controller.stub :resource => release
    end
    
    it "should download selected release" do
      release.should_receive(:download)
      get 'download', :id => 1
    end

    it "should redirect to releases_path" do
      get 'download', :id => 1
      response.should redirect_to(releases_path)
    end

  end

  describe "GET 'install'" do

    let(:release) { stub_model Release, :install => true }

    before(:each) do
      controller.stub :resource => release
    end
    
    it "should install selected release" do
      release.should_receive(:install)
      get 'install', :id => 1
    end

    it "should redirect to releases_path" do
      get 'install', :id => 1
      response.should redirect_to(releases_path)
    end

  end

end

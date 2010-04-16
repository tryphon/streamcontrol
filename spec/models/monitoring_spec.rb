require 'spec_helper'

describe Monitoring do

  before(:each) do
    FileUtils.rm_rf "tmp/munin"
    FileUtils.cp_r "public/images/munin", "tmp", :preserve => true
    Monitoring.munin_resources_directory = "tmp/munin"
  end

  describe "image" do
    it "should return the day file of given plugin" do
      Monitoring.new("if_eth0").image.should == "#{Monitoring.munin_resources_directory}/streambox.local-if_eth0-day.png"
    end

    it "should return the newest day file of given plugin when several exist" do
      newest_file = "#{Monitoring.munin_resources_directory}/streambox.local-ping_other_server-day.png"
      FileUtils.touch newest_file
      Monitoring.new("ping").image.should == newest_file
    end
  end

  describe ".find_by_plugin_name" do
    
    it "should return a new Monitoring with given plugin_name" do
      available_monitoring = stub :available? => true
      Monitoring.should_receive(:new).with(:dummy).and_return(available_monitoring)
      Monitoring.find_by_plugin_name(:dummy).should == available_monitoring
    end

    it "should return if the Monitoring isn't available" do
      Monitoring.stub :new => stub(:available? => false)
      Monitoring.find_by_plugin_name(:dummy).should be_nil
    end

  end

  describe ".all" do

    it "should return Monitorings for :ping and if_eth0" do
      Monitoring.all.collect(&:plugin_name).should == [ :ping, :if_eth0 ]
    end

    it "should not include unavailable Monitoring" do
      Monitoring.stub!(:new).and_return(stub(:available? => false))
      Monitoring.all.should be_empty
    end
    
  end

end

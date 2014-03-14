require 'spec_helper'

describe MonitoringsHelper do

  let(:monitoring) { Monitoring.new(:dummy) }

  describe "monitoring_image_tag" do

    it "should use the monitor decorator name is alt" do
      monitoring.stub :decorate => monitoring.decorate
      monitoring.decorate.stub :name => "Dummy"
      helper.monitoring_image_tag(monitoring).should have_selector("img[alt=Dummy]")
    end

    it "should use the given html options" do
      helper.monitoring_image_tag(monitoring, :class  => "dummy").should have_selector("img[class=dummy]")
    end

    it "should use the monitoring image" do
      helper.monitoring_image_tag(monitoring).should have_selector("img[src='/monitorings/dummy.png']")
    end

    it "should find the Monitoring with given plugin_name" do
      Monitoring.should_receive(:find_by_plugin_name).with(:dummy).and_return(monitoring)
      helper.monitoring_image_tag(:dummy)
    end

  end

  describe "monitoring_preview_tag" do

    it "should return nil if monitoring doesn't exist" do
      Monitoring.stub :exists? => false
      helper.monitoring_preview_tag(:dummy).should be_nil
    end

    it "should use monitorings_path in link" do
      Monitoring.stub :exists? => true
      helper.monitoring_preview_tag(:dummy).should have_selector("a[href='#{monitorings_path}']")
    end

    it "should use monitoring_image_tag as link content" do
      Monitoring.stub :exists? => true
      helper.should_receive(:monitoring_image_tag).with(:dummy, :width => 250).and_return("monitoring_image_tag")
      helper.monitoring_preview_tag(:dummy).should have_selector("a", "monitoring_image_tag")
    end

  end

end

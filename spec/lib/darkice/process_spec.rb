require 'spec_helper'

describe Darkice::Process do

  describe "by default" do

    its(:config_file) { should == "/etc/darkice.cfg" }
    its(:executable) { should == "/usr/bin/darkice" }
    it { should_not be_debug }

    its(:status) { should == :stopped }

  end

  describe "initialization" do

    it "should use the given config_file" do
      Darkice::Process.new(:config_file => "dummy").config_file.should == "dummy"
    end

  end

end

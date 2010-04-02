require 'spec_helper'

describe Darkice::Process do

  before(:each) do
    @mock_icecast = MockIcecast2.new(8000)
    @mock_icecast.start

    @darkice_process = Darkice::Process.new :config_file => "#{File.dirname(__FILE__)}/../../fixtures/darkice.cfg"
    @darkice_process.logger = Rails.logger
  end

  before(:each) do
    @mock_icecast.close
  end

  # it "should run darkice and log a Event source_started" do
  #   sleep 30
  #   Event.should_receive(:create).with(hash_including(:message => :source_started))
  #   @darkice_process.run
  # end
  

end

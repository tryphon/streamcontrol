require 'spec_helper'

describe Event do

  let(:event) { Event.new :message => "dummy", :severity => :info }

  it { should validate_presence_of(:message) }
  it { should validate_presence_of(:severity) }

  it { should ensure_inclusion_of(:severity).in_array([:error, :info]) }

  it "should remove Events older than 3 days when a new one is created" do
    old_event = Event.new(:message => "old", :severity => :info).tap do |event|
      event.created_at = 3.5.days.ago
    end
    event.save!
    Event.find_by_id(old_event).should be_nil
  end

  describe "stream" do

    it "should return the Stream identified by stream_id" do
      event.stream_id = 1
      Stream.should_receive(:find).with(1).and_return(stream = double(Stream))
      event.stream.should == stream
    end

    it "should return nil if stream_id is nil" do
      event.stream_id = nil
      event.stream.should be_nil
    end

    it "should return nil if no Stream is identified by stream_id" do
      Stream.stub :find
      event.stream.should be_nil
    end

  end
end

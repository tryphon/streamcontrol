require 'spec_helper'

describe Metadata do

  it { should validate_presence_of :song }

  let(:mock_updater) { double :update => true }
  let(:streams) { Array.new(3) { double :metadata_updater => mock_updater } }

  before(:each) do
    Stream.stub :all => streams
  end

  describe "save" do

    let(:song) { "Test Song" }

    before(:each) do
      subject.song = song
    end

    it "should return false when invalid" do
      subject.stub :valid? => false
      subject.save.should be_false
    end

    it "should update metadata on each Stream" do
      streams.each do |stream|
        stream.metadata_updater.should_receive(:update).with(song)
      end
      subject.save
    end

    it "should return true" do
      subject.save.should be_true
    end

  end

end

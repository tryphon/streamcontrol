require 'spec_helper'

describe Darkice::CLI do

  let(:cli) { Darkice::CLI.new }

  describe "default options" do

    subject { cli.options }

    it { should include(:config_file => '/etc/darkice.cfg') }
    it { should include(:executable => '/usr/bin/darkice') }

  end

  RSpec::Matchers.define :use_argument do |argument, options = {}|
    match do |cli|
      option_name = (options[:as] or argument)
      value = "dummy"

      cli.parse_options($stdout, ["--#{argument}", value])
      cli.options[option_name] == value
    end
  end

  describe "parse_options" do

    subject { cli }

    it { should use_argument(:config, :as => :config_file) }
    it { should use_argument(:executable) }
    it { should use_argument(:pidfile, :as => :pid_file) }

  end

  context "when pidfile is defined" do

    let(:cli) do
      Darkice::CLI.new.tap do |cli|
        cli.stub :pid_file => "tmp/test-cli.pid"
      end
    end

    after(:each) do
      FileUtils.rm_f(cli.pid_file)
    end

    describe "create_pidfile" do

      it "should create a pidfile with Process.pid" do
        ::Process.stub :pid => 123
        cli.create_pidfile
        File.read(cli.pid_file).should == "123\n"
      end

    end

    describe "delete_pidfile" do

      it "should delete pid file if exists" do
        FileUtils.touch cli.pid_file
        cli.delete_pidfile
        File.exists?(cli.pid_file).should be_false
      end

    end

  end

  context "when pidfile isn't defined" do

    describe "create_pidfile" do

      it "should not create a pid file " do
        File.should_not_receive(:open)
        cli.create_pidfile
      end

    end

    describe "delete_pidfile" do

      it "should not search the file" do
        File.should_not_receive(:exists?)
        cli.delete_pidfile
      end

    end

  end

  describe "process" do

    it "should create a Darkice::Process with options" do
      cli.stub :options => { :dummy => true }
      Darkice::Process.should_receive(:new).with(cli.options)
      cli.process
    end

    it "should cache the created Darkice::Process" do
      cli.process
      Darkice::Process.should_not_receive(:new)
      cli.process
    end

  end

  describe "#execute" do

    let(:stdout) { $stdout }
    let(:arguments) { ["--dummy", "true" ]}
    let(:process) { double :loop => true }

    let(:cli) do
      Darkice::CLI.new.tap do |cli|
        cli.stub :parse_options => nil, :init_signals => nil, :create_pidfile => nil, :process => process
      end
    end

    it "should parse given arguments" do
      cli.should_receive(:parse_options).with(stdout, arguments)
      cli.execute(stdout, arguments)
    end

    it "should init signals" do
      cli.should_receive(:init_signals)
      cli.execute(stdout, arguments)
    end

    it "should create pid file" do
      cli.should_receive(:create_pidfile)
      cli.execute(stdout, arguments)
    end

    it "should loop process" do
      process.should_receive(:loop)
      cli.execute(stdout, arguments)
    end

  end

end

require 'optparse'

module Darkice
  class CLI

    attr_reader :options

    def initialize
      @options = {
        :config_file => '/etc/darkice.cfg',
        :executable => '/usr/bin/darkice'
      }
    end

    def parse_options(stdout, arguments = [])
      OptionParser.new do |opts|
        opts.banner = <<-BANNER.gsub(/^          /,'')
          Start and control darkice execution and errors

          Usage: #{File.basename($0)} [options]

          Options are:
        BANNER
        opts.separator ""
        opts.on("-c", "--config PATH", String,
                "The darkice configuration file") { |arg| options[:config_file] = arg }
        opts.on("-e", "--executable PATH", String,
                "The darkice executable") { |arg| options[:executable] = arg }
        opts.on("-p", "--pidfile PATH", String,
                "The file to store the darkice-safe process id") { |arg| options[:pid_file] = arg }
        opts.on("-d", "--debug", "Output log to the console") { |arg| options[:debug] = true }
        opts.on("-h", "--help",
                "Show this help message.") { stdout.puts opts; exit }
        opts.parse!(arguments)
      end
    end

    def execute(stdout, arguments=[])
      parse_options(stdout, arguments)

      init_signals
      create_pidfile
      process.loop
    end

    def pid_file
      options[:pid_file]
    end

    def create_pidfile
      if pid_file
        File.open(pid_file, "w") { |f| f.puts ::Process.pid }
      end
    end

    def delete_pidfile
      if pid_file and File.exists?(pid_file)
        File.delete(pid_file) 
      end
    end

    def init_signals
      trap("TERM") { self.kill }
      trap("EXIT") { self.kill }
    end

    def process
      @process ||= Darkice::Process.new(options)
    end

    def kill
      @process.kill if @process
      delete_pidfile
    end

    def self.execute(stdout, arguments=[])
      self.new.execute stdout, arguments
    end

  end
end

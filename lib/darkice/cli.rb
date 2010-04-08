require 'optparse'

module Darkice
  class CLI
    def self.execute(stdout, arguments=[])
      options = {
        :config_file => '/etc/darkice.cfg',
        :executable => '/usr/bin/darkice'
      }
      mandatory_options = %w(  )

      parser = OptionParser.new do |opts|
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

        if mandatory_options && mandatory_options.find { |option| options[option.to_sym].nil? }
          stdout.puts opts; exit
        end
      end

      pid_file = options[:pid_file]
      if pid_file
        File.open(pid_file, "w") { |f| f.puts ::Process.pid }
      end

      process = Darkice::Process.new(options)

      trap("TERM") do 
        process.kill
        if pid_file and File.exists?(pid_file)
          File.delete(pid_file) 
        end
        exit 0
      end

      trap("EXIT") do 
        process.kill
        if pid_file and File.exists?(pid_file)
          File.delete(pid_file) 
        end
        exit 0
      end

      trap("CLD") do
        process.check
      end

      process.loop
    end
  end
end

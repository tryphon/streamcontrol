require 'syslog/logger'

module Darkice
  class Process
    
    attr_accessor :config_file, :executable, :status, :debug, :darkice_pid

    def initialize(options = {})
      options = {
        :config_file => "/etc/darkice.cfg",
        :executable => "/usr/bin/darkice",
        :debug => false
      }.update(options)

      @config_file = options[:config_file]
      @executable = options[:executable] 
      @debug = options[:debug] 
      @logger = options[:logger] 

      @stream_statuses = {}

      @status = :stopped
    end

    def logger
      unless debug?
        @logger ||= SyslogLogger.new("darkice")    
      else
        @logger ||= Logger.new($stdout)    
      end
    end
    attr_writer :logger

    def status=(status)
      return if self.status == status

      logger.debug "status changed: #{status}"
      if status == :running
        create_event :info, :source_started
      else
        create_event :error, "source_#{status}"
      end
      @status = status
    end

    def create_event(severity, message, other_attributes = {})
      logger.info "create new event #{severity} #{message}"
      Event.create! other_attributes.update(:severity => severity, :message => message)
    rescue => e
      logger.error "can't create event #{e}"
    end

    def last_error=(error)
      logger.debug "error detected: #{error}"
      unless same_error_than_previously? error
        @last_error_event = create_event :error, error
      end
    end

    def last_error
      @last_error_event.message if @last_error_event  
    end

    def same_error_than_previously?(error)
      @last_error_event and @last_error_event.message == error and @last_error_event.created_at > 25.seconds.ago
    end

    def debug?
      @debug
    end

    def loop
      while restart?
        run
        if restart?
          logger.info "darkice stopped, restart in 30s"
          sleep 30
        end
      end
    end

    def sleep(time)
      100.times do
        Kernel.sleep time / 100.0
        break if @killed
      end
    end

    def running?
      if self.darkice_pid
        proc_cmdline = "/proc/#{self.darkice_pid}/cmdline"
        logger.debug "check proc cmdline: #{proc_cmdline}"
        if File.exists? proc_cmdline
          process_executable = IO.read(proc_cmdline).tr("\000","\n").split.first
          logger.debug "check process command: #{process_executable.inspect}"
          process_executable and process_executable == self.executable
        end
      end
    end

    def restart?
      self.last_error != :invalid_config and not @killed 
    end

    def run
      IO.popen("#{executable} -v10 -c #{config_file}") do |output|
        self.darkice_pid = output.pid
        logger.debug "darkice process : #{self.darkice_pid}"

        begin
          while line = output.readline
            log_line line.strip
          end
        rescue EOFError
          # end of process
        end
      end

      logger.info "darkice process stopped : #{self.darkice_pid}"

      self.darkice_pid = nil
      self.status = :stopped

      self
    end

    def kill
      return if @killed

      @killed = true
      logger.info "process killed"

      if self.darkice_pid
        logger.info "kill darkice process (#{self.darkice_pid})"
        ::Process.kill 'TERM', self.darkice_pid rescue false
      end
    end

    def log_line(line)
      logger.info line
      parse_log_line line

      remove_obsolete_stream_statuses
    end

    def change_stream_status(stream_identifier, status)
      new_status = StreamStatus.new(stream_identifier, status)
      
      if @stream_statuses[stream_identifier] != new_status
        create_event :error, "stream_#{status}", :stream_id => stream_identifier + 1
        logger.debug @stream_statuses.inspect
      end

      @stream_statuses[stream_identifier] = new_status
    end

    def remove_obsolete_stream_statuses
      @stream_statuses.values.each do |stream_status|
        if stream_status.obsolete?
          @stream_statuses.delete(stream_status.stream_identifier) 
        end
      end
    end

    def parse_log_line(line)
      case line
      when /BufferedSink, new peak: /
        self.status = :running if self.status == :stopped
      when /DarkIce: DarkIce.cpp:\d+: no section \[general\] in config/,
        /DarkIce: DarkIce.cpp:\d+: unsupported stream format/,
        /DarkIce: ConfigSection.cpp:\d+: format missing in section icecast-0/,
        /DarkIce: LameLibEncoder.h:\d+: unsupported number of input channels for the encoder/,
        /DarkIce: VorbisLibEncoder.cpp:\d+: unsupported number of channels for the encoder/,
        /0 bytes transfered to the encoders/
        self.last_error = :invalid_config
      when /DarkIce: VorbisLibEncoder.cpp:\d+: vorbis lib opening underlying sink error/
        self.last_error = :invalid_stream_vorbis
      when /DarkIce: LameLibEncoder.cpp:\d+: lame lib opening underlying sink error/
        self.last_error = :invalid_stream_mp3
      when /DarkIce: FaacEncoder.cpp:\d+: faac lib opening underlying sink error/
        self.last_error = :invalid_stream_aac
      when /DarkIce: TcpSocket.cpp:\d+: gethostbyname error/
        self.last_error = :invalid_stream_server
      when /DarkIce: TcpSocket.cpp:\d+: connect error/
        self.last_error = :connection_error
      when /BufferedSink, remaining: (\d+)/
        self.last_error = :upload_problem if $1.to_i < 1000
      when /MultiThreadedConnector :: sinkThread reconnecting[ ]+([\dx]+)/
        change_stream_status($1.to_i, :reconnecting)
      when /DarkIce: OssDspSource.cpp:\d+: read error/
        self.last_error = :audio_problem
      end
    end

    def to_s
      "#{status} #{last_error}".strip
    end
  end

end

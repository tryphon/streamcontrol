require 'syslog_logger'

module Darkice
  class Process
    
    attr_accessor :config_file, :executable, :status, :last_error, :debug

    def initialize(options)
      options = {
        :config_file => "/etc/darkice.cfg",
        :executable => "/usr/bin/darkice",
        :debug => false
      }.update(options)

      @config_file = options[:config_file]
      @executable = options[:executable] 
      @debug = options[:debug] 
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
      return self.status == status

      logger.debug "status changed: #{status}"
      if status == :running
        Event.create :severity => :info, :message => :source_started
      else
        Event.create :severity => :error, :message => "source_#{status}"
      end
      @status = status
    end

    def last_error=(error)
      return if self.last_error == error
      logger.debug "error detected: #{error}"
      Event.create :severity => :error, :message => error
      @last_error = error
    end

    def debug?
      @debug
    end

    def loop
      while restart?
        run
        sleep 3 if restart?
      end
    end

    def restart?
      self.last_error != :invalid_config
    end

    def run
      IO.popen("#{executable} -v10 -c #{config_file}") do |output|
        begin
          while line = output.readline
            log_line line.strip
          end
        rescue EOFError
          # end of process
        end
      end
      self.status = :stopped
      self
    end

    def log_line(line)
      logger.info line
      parse_log_line line

      remove_obsolete_stream_statuses
    end

    def change_stream_status(stream_identifier, status)
      new_status = StreamStatus.new(stream_identifier, status)
      
      if @stream_statuses[stream_identifier] != new_status
        Event.create :severity => :error, :message => "stream_#{status}", :stream_id => stream_identifier + 1
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
        /DarkIce: DarkIce.cpp:\d: unsupported stream format:$/,
        /DarkIce: ConfigSection.cpp:\d+: format missing in section icecast-0/,
        /DarkIce: LameLibEncoder.h:\d+: unsupported number of input channels for the encoder/,
        /DarkIce: VorbisLibEncoder.cpp:\d+: unsupported number of channels for the encoder/
        self.last_error = :invalid_config
      when /DarkIce: VorbisLibEncoder.cpp:\d+: vorbis lib opening underlying sink error$/
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
      end
    end

    def to_s
      "#{status} #{last_error}".strip
    end
  end

end

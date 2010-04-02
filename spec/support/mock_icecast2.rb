class MockIcecast2

  attr_accessor :port

  def initialize(port)
    @port = port
  end

  def server
    @server ||= TCPServer.open('0.0.0.0', port)
  end

  def start
    Thread.new do 
      accept_clients
    end
  end

  def accept_clients
    available = true
    Rails.logger.debug "run"

    while available and new_session = server.accept 
      Rails.logger.debug "start new thread"
      Thread.new(new_session) do |session| 
        Rails.logger.debug "new session"
        Rails.logger.debug "Request: #{session.gets}"
        session.print "HTTP/1.1 200/OK\r\n\r\n"
        while available and line = session.gets
          # ...
        end
        session.close
      end
    end

    Rails.logger.debug "end of run"
  end

  def stop
    available = false
  end

  def close
    stop
    server.close
  end

end

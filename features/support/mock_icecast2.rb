require 'eventmachine'

class MockIcecast2

  attr_accessor :port, :http_response

  def initialize(port)
    @port = port
    reset
  end

  def reset
    @http_response = 200
  end

  def start
    thread = Thread.current
    Thread.new do 
      EM.run do
        start_em_server
      end
    end
    self
  end

  def stop
    EM.schedule do
      EM.stop
    end
  end

  def should_refuse_authentication
    @http_response = 403
  end

  def start_em_server
    EM.start_server "localhost", port, ServerConnection, self
  end

  class ServerConnection < EM::Connection
    include EM::P::LineText2

    attr_reader :mock

    def initialize(mock)
      @mock = mock
    end

    def receive_line line
      Rails.logger.debug "Receive http header: '#{line}'"

      if line.empty?
        set_text_mode
        Rails.logger.debug "Send http response: #{mock.http_response}"
        send_data "HTTP/1.0 #{mock.http_response} OK\r\n\r\n"
      end

      Rails.logger.debug "End of receive_line"
    end

    def receive_binary_data(data)
    end
    
    def receive_end_of_binary_data
      Rails.logger.debug "End of http source"
    end

  end

end

server = MockIcecast2.new(8000).start

Before do
  @server = server
end

After do
  @server.reset
end


module Darkice
  class StreamStatus

    attr_accessor :stream_identifier, :status, :time

    def initialize(stream_identifier, status, time = Time.now)
      @stream_identifier, @status, @time = stream_identifier, status, time
    end

    def obsolete?
      (Time.now - time) > 20
    end

    def to_s
      "stream_#{stream_identifier} #{status}"
    end

    def ==(other)
      other and stream_identifier == other.stream_identifier and status == other.status 
    end

  end
end

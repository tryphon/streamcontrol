class StreamPresenter

  def initialize(stream)
    @stream = stream
  end

  def format
    StreamFormatPresenter.find(@stream.format)
  end

end

class StreamPresenter

  def initialize(stream)
    @stream = stream
  end

  def format
    StreamFormatPresenter.find(@stream.format)
  end

  @@description_attributes = %w{description genre related_url}

  def blank_description_attributes?
    @@description_attributes.collect do |attribute|
      @stream.send(attribute)
    end.all?(&:blank?)
  end

end

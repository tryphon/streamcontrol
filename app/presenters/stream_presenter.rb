class StreamPresenter

  def initialize(stream)
    @stream = stream
  end

  def format
    StreamFormatPresenter.find(@stream.format)
  end

  def mode
    StreamModePresenter.find(@stream.mode)
  end

  def status_class
    @stream.enabled? ? "enabled" : "disabled"
  end

  def name_with_status
    returning([]) do |parts|
      parts << @stream.name
      if @stream.disabled?
        parts << "(#{I18n.translate('streams.disabled')})" 
      end
    end.join(" ")
  end

  @@description_attributes = %w{description genre related_url}

  def blank_description_attributes?
    @@description_attributes.collect do |attribute|
      @stream.send(attribute)
    end.all?(&:blank?)
  end

end

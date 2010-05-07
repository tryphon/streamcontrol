class EventPresenter < Presenter

  def initialize(event)
    @event = event
  end

  def localized_created_at
    I18n.localize(@event.created_at, :format => :log)
  end

  def severity_image_tag
    helpers.image_tag "#{@event.severity}.png"
  end

  def user_message
    I18n.translate("events.message.#{@event.message}", :default => default_message)
  end

  def default_message
    @event.message.to_s.humanize
  end

  def stream_link(link_provider)
    if stream = @event.stream
      link_provider.link_to stream.name, stream
    else
      @event.stream_id ? "#{Stream.human_name} #{@event.stream_id}" : ""
    end
  end

end

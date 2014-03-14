class EventDecorator < ApplicationDecorator
  delegate_all

  def localized_created_at
    I18n.localize(created_at, :format => :log)
  end

  def severity_image_tag
    helpers.image_tag "#{severity}.png"
  end

  def user_message
    I18n.translate("events.message.#{message}", :default => default_message)
  end

  def default_message
    message.to_s.humanize
  end

  def stream_link
    if stream
      helpers.link_to stream.name, stream
    else
      stream_id ? "#{Stream.human_name} #{stream_id}" : ""
    end
  end
end

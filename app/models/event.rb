class Event < ActiveRecord::Base

  validates_presence_of :message, :severity
  validates_inclusion_of :severity, :in => [ :error, :info ]
  # validates_inclusion_of :message, :in => 
  #   [ 
  #     # Errors which avoid darkice from starting
  #     :invalid_config, :invalid_stream_vorbis, :invalid_stream_mp3, 
  #     :invalid_stream_aac, :invalid_stream_server, :connection_error, 
  #     # Errors during darkice is running
  #     :upload_problem, :stream_reconnecting, 
  #     # Status of Darkice process
  #     :source_started, :source_stopped
  #   ]

  after_save :destroy_obsolete_events

  def severity
    stored_severity = read_attribute(:severity)
    stored_severity.to_sym unless stored_severity.blank?
  end

  def severity=(severity)
    write_attribute :severity, severity.to_s
  end

  def message
    stored_message = read_attribute(:message)
    stored_message.to_sym unless stored_message.blank?
  end

  def message=(message)
    write_attribute :message, message.to_s
  end

  def to_s
    "#{created_at} #{severity} #{message} #{stream_id}".strip
  end

  def presenter
    @presenter ||= EventPresenter.new(self)
  end

  def stream
    @stream ||= Stream.find(stream_id) unless stream_id.blank?
  end

  def destroy_obsolete_events
    Event.destroy_all ["created_at < ?", 7.days.ago]
  end

end

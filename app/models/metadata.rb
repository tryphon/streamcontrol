class Metadata
  include BoxControl::Model

  attr_accessor :song
  validates_presence_of :song

  def save
    return false unless valid?
    logger.info "New metadata: '#{song}'"

    Stream.all.each do |stream|
      stream.metadata_updater.update song
    end

    true
  end

end

class StreamFormatPresenter

  attr_accessor :format, :name, :wikipedia_page

  def initialize(format, name, wikipedia_page)
    @format, @name, @wikipedia_page = format, name, wikipedia_page
  end

  @@instances = 
    [ 
     StreamFormatPresenter.new(:ogg_vorbis, "Ogg/Vorbis", "Vorbis"),
     StreamFormatPresenter.new(:mp3, "MP3", "MP3"),
     StreamFormatPresenter.new(:aac, "AAC", "Advanced_Audio_Coding"),                 
    ]

  def wikipedia_url
    "http://#{I18n.locale}.wikipedia.org/wiki/#{wikipedia_page}"
  end

  def self.find(format)
    all.find { |p| p.format == format }
  end

  def self.all
    @@instances
  end

end

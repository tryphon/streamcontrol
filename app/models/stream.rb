class Stream < ActiveForm::Base
  include ActsAsIpPort
  include HostValidation

  strip_attributes!

  attr_accessor :name, :id, :description, :genre, :related_url, :enabled
  validates_presence_of :name

  attr_accessor :server, :server_type, :password, :mount_point
  acts_as_ip_port :port
  validates_presence_of :server, :server_type, :port, :password
  validates_presence_of :mount_point, :if => :icecast_server?
  validates_inclusion_of :server_type, :in => [ :icecast2, :shoutcast ]

  validates_format_of :mount_point, :with => %r{^[^/]}, :allow_blank => true

  attr_accessor :format
  validates_presence_of :format
  validates_inclusion_of :format, :in => [ :vorbis, :mp3, :aac ]

  attr_accessor :quality
  validates_presence_of :quality
  validates_numericality_of :quality, :only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 10

  validates_host :server

  def after_initialize
    self.format ||= :vorbis
    self.quality ||= 4
    self.server_type ||= :icecast2
    self.enabled = true if self.enabled.nil?

    if new_record?
      self.attributes = Stream.default_attributes.update(self.attributes)
    end
  end

  def self.default_attributes
    if reference_stream = Stream.last
      { 
        :server => reference_stream.server,
        :port => reference_stream.port,
        :description => reference_stream.description,
        :genre => reference_stream.genre,
        :related_url => reference_stream.related_url
      }.with_indifferent_access
    else
      { 
        :port => 8000
      }.with_indifferent_access
    end
  end

  def url
    "#{server}:#{port}#{path}"
  end

  def path
    mount_point and mount_point.start_with?('/') ? mount_point : "/#{mount_point}"
  end

  def server_type=(server_type)
    @server_type = server_type ? server_type.to_sym : nil
  end

  def icecast_server?
    server_type == :icecast2
  end

  def format=(format)
    @format = format ? format.to_sym : nil
  end

  def quality=(quality)
    @quality = quality ? quality.to_i : nil
  end

  def mount_point=(mount_point)
    @mount_point = mount_point ? mount_point.gsub(%r{^/}, '') : nil
  end

  alias_method :enabled?, :enabled
  def disabled?
    not enabled?
  end

  def enabled=(enabled)
    @enabled = [true, 1, "true", "1"].include?(enabled)
  end

  def toggle(attribute)
    self[attribute] = !send("#{attribute}?")
    self
  end

  def presenter
    @presenter ||= StreamPresenter.new self
  end

  @@maximum_count = 4
  cattr_accessor :maximum_count

  def self.can_create?
    count < maximum_count
  end

  def new_record?
    self.id.nil?
  end

  def to_param
    self.id.to_s
  end

  def ==(other)
    other and self.id == other.id
  end

  def update_attributes_with_save(attributes)
    update_attributes_without_save attributes
    save
  end
  alias_method_chain :update_attributes, :save

  def save(dont_valid = false)
    return false if respond_to?(:valid?) and not valid? and not dont_valid

    self.id ||= (Stream.all.collect(&:id).max or 0) + 1
    PuppetConfiguration.load.update_attributes(self.attributes, "stream_#{self.id}").save
  end

  def destroy
    unless new_record?
      streams = Stream.all
      PuppetConfiguration.transaction do
        PuppetConfiguration.load.clear("stream_")
        streams.delete self

        streams.each_with_index do |stream, index|
          stream.id = index + 1
          stream.save(true)
        end
      end
    end
  end

  def self.all
    config = PuppetConfiguration.load
    (1..4).collect do |n|
      attributes = config.attributes("stream_#{n}")
      unless attributes.blank?
        Stream.new attributes.update(:id => n) 
      end
    end.compact
  end

  def self.count
    all.size
  end

  def self.find(id)
    id = id.to_i
    all.find { |stream| stream.id == id }
  end

  def self.last
    all.last
  end

end

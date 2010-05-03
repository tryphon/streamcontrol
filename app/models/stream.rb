class Stream < ActiveForm::Base
  include ActsAsIpPort
  include HostValidation

  strip_attributes!

  attr_accessor :name, :id, :description, :genre, :related_url
  validates_presence_of :name

  attr_accessor :server, :password, :mount_point
  acts_as_ip_port :port
  validates_presence_of :server, :port, :mount_point, :password

  validates_format_of :mount_point, :with => %r{^[^/]}

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
    if new_record?
      self.server ||= Stream.default_server
      self.port ||= Stream.default_port
    end
  end

  def self.stream_by_default(&block)
    stream = Stream.all.last
    if stream and block_given?
      yield stream
    else
      stream
    end
  end

  def self.default_server
    stream_by_default(&:server)
  end

  def self.default_port
    stream_by_default(&:port) or 8000
  end

  def url
    "#{server}:#{port}#{path}"
  end

  def path
    mount_point and mount_point.start_with?('/') ? mount_point : "/#{mount_point}"
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

end

class Stream < ActiveForm::Base
  include ActsAsIpPort
  include HostValidation

  strip_attributes!

  attr_accessor :name, :id
  attr_accessor :server, :password, :mount_point
  acts_as_ip_port :port

  validates_presence_of :name, :server, :port, :mount_point, :password
  validates_host :server

  def url
    "#{server}:#{port}#{path}"
  end

  def path
    mount_point.start_with?('/') ? mount_point : "/#{mount_point}"
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
    logger.debug "save"
    return false if respond_to?(:valid?) and not valid? and not dont_valid

    self.id ||= (Stream.all.collect(&:id).max or 0) + 1
    PuppetConfiguration.load.update_attributes(self.attributes, "stream_#{self.id}").save
    logger.debug PuppetConfiguration.load.inspect
  end

  def destroy
    unless new_record?
      streams = Stream.all
      PuppetConfiguration.load.clear("stream_").save
      streams.delete self

      streams.each_with_index do |stream, index|
        stream.id = index + 1
        stream.save(true)
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

  def self.find(id)
    id = id.to_i
    all.find { |stream| stream.id == id }
  end

end

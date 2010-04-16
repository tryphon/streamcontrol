class Monitoring < ActiveForm::Base

  attr_accessor :plugin_name

  def initialize(plugin_name)
    @plugin_name = plugin_name
  end

  @@munin_resources_directory = nil
  cattr_accessor :munin_resources_directory

  def image
    plugin_images.max_by { |f| File.mtime(f) }
  end

  def to_param
    plugin_name.to_s
  end

  def available?
    not image.nil?
  end

  def plugin_images
    Dir["#{munin_resources_directory}/*-#{plugin_name}*-day.png"]
  end

  def self.find(plugin_name)
    monitoring = find_by_plugin_name(plugin_name)
    raise ActiveRecord::RecordNotFound unless monitoring
    monitoring
  end

  def self.find_by_plugin_name(plugin_name)
    monitoring = Monitoring.new(plugin_name)
    monitoring if monitoring.available?
  end
  
  def self.all
    [:ping, :if_eth0].collect do |plugin_name| 
      Monitoring.new(plugin_name)
    end.find_all(&:available?)
  end

  def presenter
    @presenter ||= MonitoringPresenter.new self
  end

  def self.exists?(plugin_name)
    Monitoring.new(plugin_name).available?
  end

end

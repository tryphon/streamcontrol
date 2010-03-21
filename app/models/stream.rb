class Stream < ActiveForm::Base
  include PuppetConfigurable

  include ActsAsIpPort
  include HostValidation

  strip_attributes!

  attr_accessor :server, :password, :mount_point
  acts_as_ip_port :port

  validates_presence_of :server, :port, :mount_point, :password
  validates_host :server

  def new_record?
    false
  end

end

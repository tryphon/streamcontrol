class Stream < ActiveForm::Base
  include PuppetConfigurable

  attr_accessor :server, :port, :password, :mount_point

  validates_presence_of :server

  def new_record?
    false
  end

end

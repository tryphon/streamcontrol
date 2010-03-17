class Stream < ActiveForm::Base

  attr_accessor :server, :port, :password, :mount_point

  validates_presence_of :server

  def new_record?
    false
  end

  def self.load
    Stream.new
  end

  def save
    true
  end

end

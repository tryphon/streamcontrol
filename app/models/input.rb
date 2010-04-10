class Input < ActiveForm::Base
  include PuppetConfigurable

  attr_accessor :frequency, :volume, :gain

  with_options :if => :has_tuner? do |tuner|
    tuner.validate :must_use_valid_frequency
  end

  def after_initialize
    self.frequency ||= "107.7"
    self.volume ||= "100"
    self.gain ||= "0"
  end

  def has_tuner?
    File.exists?("/dev/radio0")
  end

  def new_record?
    false
  end

  def presenter
    @presenter ||= InputPresenter.new(self)
  end

  private

  def must_use_valid_frequency
    if ( frequency.to_f < 87.5 or frequency.to_f > 108.0 )
      errors.add(:frequency, :frequency_out_of_range)
    end
  end

end

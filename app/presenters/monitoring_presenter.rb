class MonitoringPresenter

  def initialize(monitoring)
    @monitoring = monitoring
  end

  def name
    I18n.translate("monitorings.#{@monitoring.plugin_name}")
  end

end

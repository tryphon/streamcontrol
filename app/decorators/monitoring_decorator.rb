class MonitoringDecorator < ApplicationDecorator
  delegate_all

  def name
    I18n.translate("monitorings.#{plugin_name}")
  end
end

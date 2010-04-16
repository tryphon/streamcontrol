module MonitoringsHelper
  
  def monitoring_preview_tag(plugin_name, html_options = {})
    html_options = { :width => 250 }.update(html_options)
    if Monitoring.exists? plugin_name
      link_to monitoring_image_tag(plugin_name, html_options), monitorings_path
    end
  end

  def monitoring_image_tag(monitoring, html_options = {})
    monitoring = Monitoring.find_by_plugin_name(monitoring) if Symbol === monitoring
    return nil unless monitoring

    html_options = { :alt => monitoring.presenter.name }.update(html_options)
    image_tag monitoring_path(monitoring, :format => :png), html_options
  end

end

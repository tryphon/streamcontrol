class ReleasePresenter

  def initialize(release)
    @release = release
  end

  def human_status
    I18n.translate("releases.status.#{@release.status}", :default => default_status)
  end

  def default_status
    @release.status.to_s.humanize
  end

end

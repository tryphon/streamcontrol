class ReleasesController < InheritedResources::Base

  before_filter :check_releases

  actions :index

  def index
    index! do |format|
      format.html do
        @current = Release.current
        @latest = Release.latest
      end
    end
  end

  def download
    resource.download
    redirect_to releases_path
  end

  def install
    resource.install
    redirect_to releases_path
  end

  private

  def check_releases
    Release.check
  end

end

class MonitoringsController < InheritedResources::Base

  actions :show, :index
  # respond_to :html

  def show
    show! do |format|
      format.png { send_file resource.image, :type => :png }
    end
  end

  protected

  def collection
    @monitorings ||= Monitoring.all
  end

end

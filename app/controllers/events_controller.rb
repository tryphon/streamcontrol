class EventsController < InheritedResources::Base

  actions :index
  respond_to :html, :xml, :json

  protected

  def resource
    super.decorate
  end

  def collection
    @events ||= end_of_association_chain.paginate(:page => params[:page], :order => "created_at DESC", :per_page => 15).decorate
  end

end

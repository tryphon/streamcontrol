# encoding: utf-8

class StreamsController < InheritedResources::Base

  actions :all
  respond_to :html, :xml, :json

  def show
    @events = EventDecorator.decorate_collection(resource.events.first(15))
    show!
  end

  def toggle
    resource.toggle
    redirect_to :back
  end

  protected

  def collection
    @streams ||= Stream.all
  end

end

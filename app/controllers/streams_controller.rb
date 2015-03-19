# encoding: utf-8

class StreamsController < InheritedResources::Base

  actions :all
  respond_to :html, :xml, :json

  def show
    @events = EventDecorator.decorate_collection(resource.events)
    show!
  end

  def toggle
    resource.toggle :enabled
    resource.save
    redirect_to :back
  end

  protected

  def collection
    @streams ||= Stream.all
  end

end

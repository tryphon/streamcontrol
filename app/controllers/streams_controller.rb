# -*- coding: undecided -*-
class StreamsController < InheritedResources::Base

  actions :all
  respond_to :html, :xml, :json

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

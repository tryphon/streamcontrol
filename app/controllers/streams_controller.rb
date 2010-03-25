# -*- coding: undecided -*-
class StreamsController < InheritedResources::Base

  actions :all
  respond_to :html, :xml, :json

  protected

  def collection
    @streams ||= Stream.all
  end

  def resource
    @stream ||= Stream.find(params[:id])
  end

end

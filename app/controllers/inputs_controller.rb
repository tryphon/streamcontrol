# -*- coding: utf-8 -*-
class InputsController < InheritedResources::Base

  actions :show, :edit, :update
  respond_to :html, :xml, :json

  protected

  def resource
    @input ||= Input.current
  end

end

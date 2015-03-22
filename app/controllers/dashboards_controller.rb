class DashboardsController < ApplicationController

  def show
    @events = EventDecorator.decorate_collection(Event.latest).first(15)
  end

end

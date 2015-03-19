class DashboardsController < ApplicationController

  def show
    @events = EventDecorator.decorate_collection(Event.latest)
  end

end

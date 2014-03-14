class DashboardsController < ApplicationController

  def show
    @events = Event.order("created_at DESC").limit(5).decorate
  end

end

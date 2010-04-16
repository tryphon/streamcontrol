class DashboardsController < ApplicationController

  def show
    @events = Event.find(:all, :order => "created_at DESC", :limit => 5)
  end

end

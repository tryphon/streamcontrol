class WelcomeController < ApplicationController

  def index
    redirect_to stream_path
  end
  
end

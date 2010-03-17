# -*- coding: undecided -*-
class StreamsController < ApplicationController

  def show
    @stream = Stream.load
  end

  def edit
    @stream = Stream.load
  end

  def update
    @stream = Stream.new(params[:stream])
    if @stream.save
      flash[:success] = "La configuration a été modifiée avec succès"
      redirect_to stream_path
    else
      flash[:failure] = "La configuration n'a pu été modifiée"
      render :action => "edit"
    end
  end

end

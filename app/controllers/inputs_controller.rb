# -*- coding: utf-8 -*-
class InputsController < ApplicationController

  def show
    @input = Input.load
  end

  def edit
    @input = Input.load
  end

  def update
    @input = Input.new(params[:input])
    if @input.save
      flash[:success] = "La configuration a été modifiée avec succès"
      redirect_to input_path
    else
      flash[:failure] = "La configuration n'a pu été modifiée"
      render :action => "edit"
    end
  end

end

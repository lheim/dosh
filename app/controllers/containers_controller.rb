class ContainersController < ApplicationController

  def show
    @container = Docker::Container.get(params[:id])
  end


end

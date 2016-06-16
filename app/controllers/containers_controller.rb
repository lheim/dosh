class ContainersController < ApplicationController

  def index
    @containers = Docker::Container.all(:all => true)
  end

  def show
    @container = Docker::Container.get(params[:id])
  end


  def start
    @container = Docker::Container.get(params[:id])
    @container.start

    redirect_to container_path, success: "container sucessfully started."

  end

  def stop
    @container = Docker::Container.get(params[:id])
    @container.stop


    state = @container.info['State']['Status']
    if state == 'exited'
      flash[:success] = 'container sucessfully stopped.'
      redirect_to container_path
    else
      flash[:error] = 'container failed to stop.'
      redirect_to container_path
    end
  end

  def restart

  end

  def remove

  end

  def commit

  end

  def new

  end


end

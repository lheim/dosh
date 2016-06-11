class ContainersController < ApplicationController

  def show
    @container = Docker::Container.get(params[:id])
  end


  def start
    @container = Docker::Container.get(params[:id])
    @container.start

    state = @container.info['State']
    if state == 'running'
      flash[:success] = 'container sucessfully started.'
    else
      flash[:error] = 'container failed to start.'
    end
  end

  def stop

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

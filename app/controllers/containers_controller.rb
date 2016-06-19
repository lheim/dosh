class ContainersController < ApplicationController

  def index
    @containers = Docker::Container.all(:all => true)
  end

  def show
    @container = Docker::Container.get(params[:id])
    @logs = @container.logs(stdout: true, stderr: true)

    #@container.tap(&:start).attach(stdin: StringIO.new("foo\nbar\n"))
  end


  def start
    @container = Docker::Container.get(params[:id])
    @container.start
    #redefine @container
    @container = Docker::Container.get(params[:id])
    state = @container.info['State']['Status']
    if state == 'running'
      redirect_to container_path, success: "container successfully started."
    else
      redirect_to container_path, error: "container failed to start."
    end
  end

  def stop
    @container = Docker::Container.get(params[:id])
    @container.stop
    #redefine @container
    @container = Docker::Container.get(params[:id])
    state = @container.info['State']['Status']
    if state == 'exited'
      redirect_to container_path, success: "container successfully stopped."
    else
      redirect_to container_path, error: "container failed to stop."
    end
  end

  def restart
    @container = Docker::Container.get(params[:id])
    @container.restart
    #redefine @container
    @container = Docker::Container.get(params[:id])
    state = @container.info['State']['Status']
    if state == 'running'
      redirect_to container_path, success: "container successfully restarted."
    else
      redirect_to container_path, error: "container failed to restart."
    end
  end

  def remove
    @container = Docker::Container.get(params[:id])
    state = @container.info['State']['Status']
    if state == 'exited' || state == 'created'
    @container.remove
      redirect_to containers_path, success: "container was successfully removed."
    elsif state == 'running'
      redirect_to container_path, error: "stop the container first before removing."
    else
      redirect_to container_path, error: "unknown error: couldn't be removed. container status is unknown."
    end
  end

  def commit
    @container = Docker::Container.get(params[:id])
    @container.commit
    redirect_to container_path, success: "container successfully committed."
  end


  def rename

    @container = Docker::Container.get(params[:id])
    @container.rename(params[:name])

    redirect_to container_path, success: "container succesfully renamed to '#{params[:name]}'."
  end

  #page to create a new container
  def new
    @images = Docker::Image.all
  end

  def create



    container_params = Hash.new
    container_params['Hostname'] = params[:hostname]
    container_params['Image'] = params[:image]
    container_params['Tty'] = true
    puts params[:tty]


    @container = Docker::Container.create(container_params)

    #set the name of the container
    @container.rename(params[:name])


    redirect_to containers_path, success: "container '#{params[:name]}' was successfully created."

  end


end

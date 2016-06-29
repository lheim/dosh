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


    #create hash with all given options
    container_params = Hash.new

    #hostname
    if !params[:hostname].blank?
      container_params['Hostname'] = params[:hostname]
    end

    #image
    container_params['Image'] = params[:image]

    #command
    if !params[:command].blank?
      container_params['Cmd'] = params[:command]
    end

    #enviroment variables
    if !params[:env].blank?
      
      container_params['Env'] = params[:env]

      puts params[:env]
    end


    #tty enabled
    if params[:tty] == 'true'
      container_params['Tty'] = true
    else
      container_params['Tty'] = false
    end

    #privileged mode
    if params[:privileged] == 'true'
      privi = {"Privileged" => true}
    else
      privi = {"Privileged" => false}
    end

    container_params['HostConfig']= privi



    networkmode = {"NetworkMode" => params[:network]}
    container_params['HostConfig'].merge!(networkmode)


    if !params[:port_in].blank?
      exposedports = {"#{params[:port_in]}" => {}}
      container_params['ExposedPorts'] = exposedports
      if !params[:port_out].blank?
        bindingports = {"PortBindings" => {"#{params[:port_in]}" => [{"HostPort" => "#{params[:port_out]}"}]}}
        container_params['HostConfig'].merge!(bindingports)
      end
    end

    #volume binding
    if ((!params[:volume_host].blank?) && (!params[:volume_container].blank?) && (params[:volume_mode] == "read/write"))
      binds = {"Binds" => ["#{params[:volume_host]}:#{params[:volume_container]}"]}
      container_params['HostConfig'].merge!(binds)
    elsif ((!params[:volume_host].blank?) && (!params[:volume_container].blank?) && (params[:volume_mode] == "read-only"))
      binds = {"Binds" => ["#{params[:volume_host]}:#{params[:volume_container]}:ro"]}
      container_params['HostConfig'].merge!(binds)
    end
    puts binds


    puts container_params


    @container = Docker::Container.create(container_params)

    #set the name of the container
    if !params[:name].blank?
      @container.rename(params[:name])
      name = params[:name]
    #no name given, name is randomly chosen
    else
      name = @container.info['id'].truncate(12, omission: '')
    end


    redirect_to containers_path, success: "container '#{name}' was successfully created."

  end


end

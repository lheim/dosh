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


    if !params[:port_in1].blank?
      exposedports = {"#{params[:port_in1]}" => {}}
      container_params['ExposedPorts'] = exposedports
      if !params[:port_out1].blank?
        portbindings = {"PortBindings" => 0}
        container_params['HostConfig'].merge!(portbindings)
        bindingports = {"#{params[:port_in1]}" => [{"HostPort" => "#{params[:port_out1]}"}]}
        container_params['HostConfig']['PortBindings'] = (bindingports)
      end
    end


    if !params[:port_in2].blank?
      exposedports = {"#{params[:port_in2]}" => {}}
      container_params['ExposedPorts'].merge! exposedports
      if !params[:port_out2].blank?
        bindingports = {"#{params[:port_in2]}" => [{"HostPort" => "#{params[:port_out2]}"}]}
        container_params['HostConfig']['PortBindings'].merge!(bindingports)
      end
    end



    #volume binding
    if ((!params[:volume_host1].blank?) && (!params[:volume_container1].blank?) && (params[:volume_mode1] == "read/write"))
      bindsvalue = {"Binds" => 0}
      container_params['HostConfig'].merge!(bindsvalue)
      binds = ["#{params[:volume_host1]}:#{params[:volume_container1]}"]
      container_params['HostConfig']['Binds'] = (binds)
    elsif ((!params[:volume_host1].blank?) && (!params[:volume_container1].blank?) && (params[:volume_mode1] == "read-only"))
      bindsvalue = {"Binds" => 0}
      container_params['HostConfig'].merge!(bindsvalue)
      binds = ["#{params[:volume_host1]}:#{params[:volume_container1]}:ro"]
      container_params['HostConfig']['Binds'] = (binds)
    end

    puts 'VOLUMES1'
    puts container_params['HostConfig']


    # if ((!params[:volume_host2].blank?) && (!params[:volume_container2].blank?) && (params[:volume_mode2] == "read/write"))
    #   binds = ["#{params[:volume_host2]}:#{params[:volume_container2]}"]
    #   container_params['HostConfig']['Binds'].merge!(binds)
    # elsif ((!params[:volume_host2].blank?) && (!params[:volume_container2].blank?) && (params[:volume_mode2] == "read-only"))
    #   binds = ["#{params[:volume_host2]}:#{params[:volume_container2]}:ro"]
    #   container_params['HostConfig']['Binds'].merge!(binds)
    # end


    #memory Reservation
    if !params[:memory].blank?
        metric = params[:memory].last(1)
        if metric == 'M'
          memory = 1024*1024 * params[:memory].to_i
        elsif metric == 'G'
          memory = 1024*1024*1024 * params[:memory].to_i
        else
          memory = params[:memory].to_i
        end
        container_params['HostConfig']['Memory'] = memory
    end



    #cpu share
    if !params[:cpushare].blank?
        container_params['HostConfig']['CpuShares'] = params[:cpushare].to_i
    end

    puts container_params

    #try to create container
    begin
      @container = Docker::Container.create(container_params)
    rescue => error
      redirect_to '/containers', error: "error message: '#{error}'"
      return
    end

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

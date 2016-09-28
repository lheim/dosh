class ContainersController < ApplicationController

  def index
    begin
      @containers = Docker::Container.all(:all => true)
    rescue => error
      redirect_to '/error', error: "error: #{error}"
      return
    end
  end

  def show
    begin
      @container = Docker::Container.get(params[:id])
    rescue => error
      redirect_to '/error', error: "error: #{error}"
      return
    end
    @logs = @container.logs(stdout: true, stderr: true)
    @name = @container.info['Name'][1..-1]

    @usrp = Usrp.find_by(assigned: @name)




    #@container.tap(&:start).attach(stdin: StringIO.new("foo\nbar\n"))
  end


  def start
    begin
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
    rescue => error
      redirect_to '/error', error: "error: #{error}"
      return
    end
  end

  def stop
    begin
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
    rescue => error
      redirect_to '/error', error: "error: #{error}"
      return
    end
  end

  def pause
    begin
      @container = Docker::Container.get(params[:id])
      @container.pause
      #redefine @container
      @container = Docker::Container.get(params[:id])
      puts state = @container.info['State']['Status']
      if state == 'paused'
        redirect_to container_path, success: "container successfully paused."
      else
        redirect_to container_path, error: "container failed to pause."
      end
    rescue => error
      redirect_to '/error', error: "error: #{error}"
      return
    end
  end


  def unpause
    begin
      @container = Docker::Container.get(params[:id])
      @container.unpause
      #redefine @container
      @container = Docker::Container.get(params[:id])
      puts state = @container.info['State']['Status']
      if state == 'running'
        redirect_to container_path, success: "container successfully unpaused."
      else
        redirect_to container_path, error: "container failed to unpause."
      end
    rescue => error
      redirect_to '/error', error: "error: #{error}"
      return
    end
  end

  def restart
    begin
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
    rescue => error
      redirect_to '/error', error: "error: #{error}"
      return
    end
  end

  def remove
    begin
      @container = Docker::Container.get(params[:id])
      state = @container.info['State']['Status']
      if state == 'exited' || state == 'created'
        # remove assigned usrp
        if usrpDB = Usrp.find_by(assigned: @container.info['Name'][1..-1])
          usrpDB.assigned = '- free -'
          usrpDB.save
        end
        @container.remove
        redirect_to containers_path, success: "container was successfully removed."
      elsif state == 'running'
        redirect_to container_path, error: "stop the container first before removing."
      else
        redirect_to container_path, error: "unknown error: couldn't be removed. container status is unknown."
      end
    rescue => error
      redirect_to '/error', error: "error: #{error}"
      return
    end
  end

  def commit
    begin
      @container = Docker::Container.get(params[:id])
      @container.commit
      redirect_to container_path, success: "container successfully committed."
    rescue => error
      redirect_to '/error', error: "error: #{error}"
      return
    end
  end


  def rename
    begin
      @container = Docker::Container.get(params[:id])
      @container.rename(params[:name])
      redirect_to container_path, success: "container succesfully renamed to '#{params[:name]}'."
    rescue => error
      redirect_to '/error', error: "error: #{error}"
      return
    end
  end

  #page to create a new container
  def new
    @images = Docker::Image.all
    @usrps = Usrp.all
    @nodes = Node.all
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

    #env variables
    if !params[:env].blank? || !params[:nodes].blank? || !params[:usrp].blank?
      env = Array.new
      if !params[:env].blank?
        env = params[:env].split
      end

      if !params[:nodes].blank?

        constraint = params[:node].split
        env.push("constraint:node==#{constraint[0]}")

      end


      if !params[:usrp].blank?

        usrp = params[:usrp][/\(.*?\)/].delete('()')
        env.push("USRP_IP=#{usrp}")

        # add this container id to USRP DB


      end


      container_params['Env'] = env

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


    #network mode (bridge, host, etc.)
    networkmode = {"NetworkMode" => params[:network]}
    container_params['HostConfig'].merge!(networkmode)

    #port binding #1
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

    #port binding #2
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
      binds = Array.new
      binds[0] = "#{params[:volume_host1]}:#{params[:volume_container1]}"
      container_params['HostConfig']['Binds'] = (binds)

    #readonly
    elsif ((!params[:volume_host1].blank?) && (!params[:volume_container1].blank?) && (params[:volume_mode1] == "read-only"))
      bindsvalue = {"Binds" => 0}
      container_params['HostConfig'].merge!(bindsvalue)
      binds = Array.new
      binds[0] = "#{params[:volume_host1]}:#{params[:volume_container1]}:ro"
      container_params['HostConfig']['Binds'] = binds
    end


    #VOLUME #2
    if ((!params[:volume_host2].blank?) && (!params[:volume_container2].blank?) && (params[:volume_mode2] == "read/write"))
      binds[1] = "#{params[:volume_host2]}:#{params[:volume_container2]}"
      container_params['HostConfig']['Binds'] = binds
    #readonly
    elsif ((!params[:volume_host2].blank?) && (!params[:volume_container2].blank?) && (params[:volume_mode2] == "read-only"))
      binds[1] = "#{params[:volume_host2]}:#{params[:volume_container2]}:ro"
      container_params['HostConfig']['Binds'] = binds
    end


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

    #cpu period
    if !params[:cpuperiod].blank?
        container_params['HostConfig']['CpuPeriod'] = params[:cpuperiod].to_i
    end

    #cpuquota
    if !params[:cpuquota].blank?
        container_params['HostConfig']['CpuQuota'] = params[:cpuquota].to_i
    end

    #cpusetcpus
    if !params[:cpuset].blank?
        container_params['HostConfig']['CpusetCpus'] = params[:cpuset]
    end

    puts 'WHOLE PARAMS THING'
    puts container_params

    #try to create container
    begin
      Timeout.timeout(3) do
        @container = Docker::Container.create(container_params)
      end
    rescue => error
      redirect_to '/containers', error: "error message: '#{error}'"
      return
    end

    #set the name of the container
    if !params[:name].blank?
      begin
        @container.rename(params[:name])
        name = params[:name]
      rescue => error
        name = @container.info['id'].truncate(12, omission: '')
      end
    #no name given, name is randomly chosen
    else
        container = Docker::Container.get(@container.info['id'].truncate(12, omission: ''))
        name = container.info['Name'][1..-1]
    end

    # add container to USRP DB if USRP was assigned
    if !params[:usrp].blank?
      usrpDB = Usrp.find_by(ip: usrp)
      usrpDB.assigned = name
      if !usrpDB.save
        redirect_to containers_path, error: "container '#{name}' was successfully created. BUT assigned container is not written to USRP db."
        return
      end
    end

    redirect_to containers_path, success: "container '#{name}' was successfully created."

  end


end

class NodesController < ApplicationController
  def index


    @nodes = Node.all
    @node = Node.new

    begin
      @info = Docker.info
    rescue => error
      redirect_to '/error', error: "error: #{error}"
      return
    end

  end




  def addtodb

    #node is already in db
    if Node.find_by(ip: params[:ip])
      redirect_to nodes_path, error: "node with ip '#{params[:ip]}'"
    #new node
    else
      node_params = Hash.new
      node_params['nodename'] = params['nodename']
      node_params['ip'] = params['ip']
      node_params['os'] = params['os']

      @node = Node.new(node_params)

      if @node.save
        redirect_to nodes_path, success: "node '#{node_params['nodename']}' added to db"
      else
        redirect_to nodes_path, error: "failed to add node to db"
      end
    end
  end

  def removefromswarm

    #save manager url
    manager_url = Docker.url
    #connect to docker engine of node
    puts Docker.url = "tcp://#{params[:ip]}"

    #check for existing agent (norm: is named 'swarm-agent'), jep it's that bad.
    begin
      Timeout.timeout(10) do
        agent_container = Docker::Container.get('swarm-agent')

        state = agent_container.info['State']['Status']
        if state == 'exited'
          redirect_to nodes_path, error: "swarm-agent container is already stopped."
        else
          agent_container.stop
          agent_container = Docker::Container.get('swarm-agent')
          state = agent_container.info['State']['Status']
          if state == 'exited'
            redirect_to nodes_path, success: "swarm container from '#{params[:ip]}' successfully stopped. it may take some minutes."
          else
            redirect_to nodes_path, error: "swarm container from from '#{params[:ip]}' failed to stop."
          end
        end
      end
    #OOPS
    rescue => error
        redirect_to nodes_path, error: "error: '#{error}'"
    end

    #go back to manager engine
    Docker.url = manager_url
  end

  def addtoswarm


    #save manager url
    manager_url = Docker.url
    #connect to docker engine of node
    puts Docker.url = "tcp://#{params[:ip]}"

    #check for existing agent (norm: is named 'swarm-agent'), jep it's that bad.
    begin
      Timeout.timeout(10) do
        agent_container = Docker::Container.get('swarm-agent')

        state = agent_container.info['State']['Status']
        if state == 'running'
          redirect_to nodes_path, error: "swarm-agent container is already running."
        else
          agent_container.start
          redirect_to nodes_path, success: "node from '#{params[:ip]}' was added to swarm. wait a minute."
        end
      end
    #OOPS
    rescue => error
        redirect_to nodes_path, error: "error: '#{error}'"
    end

    #go back to manager engine
    Docker.url = manager_url

  end

  def delete
    if Node.destroy(params[:id])
      redirect_to '/nodes', success: "node (id: '#{params['id']}') was removed from db."
    else
      render 'index', error: "failed to remove node from db."
    end

  end



end

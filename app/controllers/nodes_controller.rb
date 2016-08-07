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


    node_params = Hash.new
    node_params['nodename'] = params['nodename']
    node_params['ip'] = params['ip']
    node_params['os'] = params['os']


    @node = Node.new(node_params)

    if @node.save
      redirect_to '/nodes', success: "node '#{node_params['nodename']}' added to db"
    else
      render 'index', error: "failed to add node to db"
    end

  end

  def removefromswarm
    @container = Docker::Container.get(params[:name])
    @container.stop
    #redefine @container
    @container = Docker::Container.get(params[:name])
    state = @container.info['State']['Status']
    if state == 'exited'
      redirect_to nodes_path, success: "swarm container successfully stopped. it may take some minutes."
    else
      redirect_to nodes_path, error: "swarm container failed to stop."
    end
  end

  def addtoswarm
    Docker::Connection.new('tcp://192.168.99.103:2376', {})
    redirect_to nodes_path, success: "node was added to swarm. wait a minute."
  end

  def delete
    if Node.destroy(params[:id])
      redirect_to '/nodes', success: "node (id: '#{params['id']}') was removed from db."
    else
      render 'index', error: "failed to remove node from db."
    end

  end



end

class NodesController < ApplicationController
  def index


    @nodes = Node.all
    @node = Node.new

    @info = Docker.info

  end

  def addtodb



    #puts i = params[:id]





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

    redirect_to container_path, success: "node was removed from swarm. wait a minute."
  end

  def addtoswarm

    redirect_to container_path, success: "node was added to swarm. wait a minute."
  end





end

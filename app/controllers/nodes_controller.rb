class NodesController < ApplicationController
  def index


    @nodes = Node.all
    @node = Node.new

    @info = Docker.info

  end


  def removefromswarm

  end

  def addtoswarm

  end
  
end

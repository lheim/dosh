class NodesController < ApplicationController
  def index


    @nodes = Node.all
    @node = Node.new

    @info = Docker.info

  end
end

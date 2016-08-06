class HomeController < ApplicationController
  def index
    @containers = Docker::Container.all(:all => true)
    @info = Docker.info
  end
end

class HomeController < ApplicationController
  def index
    begin
      @containers = Docker::Container.all(:all => true)
    rescue => error
      redirect_to '/error', error: "error: #{error}"
      return
    end

    @info = Docker.info


  end
end

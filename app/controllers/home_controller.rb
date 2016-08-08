class HomeController < ApplicationController
  def index
    begin
      Timeout.timeout(5) do
        @containers = Docker::Container.all(:all => true)
      end
    rescue => error
      redirect_to '/error', error: "error: #{error}"
      return
    end

    @info = Docker.info


  end
end

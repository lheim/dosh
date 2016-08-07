module NodesHelper

  def up(ip)


    manager_url = Docker.url
    #connect to docker engine of node
    Docker.url = "tcp://#{ip}"

    #try to connect to docker engine
    begin
      Timeout.timeout(0.2) do
        Docker.validate_version!
        Docker.url = manager_url
        return true
      end
    #OOPS
    rescue
        Docker.url = manager_url
        return false
    end
    #go back to manager engine
  end

end

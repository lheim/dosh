module UsrpsHelper


  def ping(host)
    begin
      Timeout.timeout(0.01) do
        ping = `ping -c 1 #{host}`
        return true
      end
    rescue
      return false
    end
  end





end

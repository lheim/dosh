class UsrpsController < ApplicationController

  @stdout_probe = 'EMPTY IN BEGGNING'

  def index
    require 'open3'
    begin
      @stdout, @stderr, @status = Open3.capture3('uhd_find_devices')

      @found_usrps = Hash.new
      i = -1

      @stdout.each_line do |line|

        # new uhd device
        if line.include? 'UHD Device'
          i += 1
          @found_usrps[i] = Hash.new()

        elsif line.include? 'type'
          @found_usrps[i]["type"] = line.split[1]
        elsif line.include? 'addr'
          @found_usrps[i]["addr"] = line.split[1]
        elsif line.include? 'name'
          @found_usrps[i]["name"] = line.split[1]
        elsif line.include? 'serial'
          @found_usrps[i]["serial"] = line.split[1]

        end
      end
      # puts @found_usrps
      puts "USRP PROBE DATA", @stdout_probe

    rescue Errno::ENOENT
      redirect_to '/', error: "uhd is not installed on the system."
    end

    @usrp = Usrp.new
    @usrps = Usrp.all


    #
    # print @stdout
    # print @stdeerr
    # print @status

  end


  #check/discovery for new usrp
  def refresh

  end

  # probe usrp for more information
  # NEEDS WORK
  def probe
    begin
      puts "uhd_usrp_probe --arg=\"addr=#{params[:usrp_ip]}\""
      @stdout_probe,@@stderr_probe, @status_probe = Open3.capture3("uhd_usrp_probe --arg=\"addr=#{params[:usrp_ip]}\"")

      puts @stdout_probe, @stderr_probe, @status_probe


    rescue Errno::ENOENT
      redirect_to '/', error: "uhd is not installed on the system."
    end

  redirect_to '/usrps', success: "USRP (ip: #{params[:usrp_ip]}) was successfully probed."


  end



  #add discovered usrp to database
  def create
    # check for more info with usrp probe
    begin
      puts "uhd_usrp_probe --arg=\"addr=#{params[:usrp_ip]}\""
      @stdout_probe, @stderr_probe, @status_probe = Open3.capture3("uhd_usrp_probe --arg=\"addr=#{params[:usrp_ip]}\"")

      usrp_params = Hash.new

      @stdout_probe.each_line do |line|

        # new uhd device
        if line.include? 'Mboard'
          usrp_params[:model] = line.split[3]
        end
      end

    rescue Errno::ENOENT
      redirect_to '/', error: "uhd is not installed on the system."
    end

    usrp_params[:ip] = params[:usrp_ip]

    @usrp = Usrp.new(usrp_params)
    if @usrp.save
      redirect_to '/usrps', success: "USRP '#{usrp_params[:ip]}' added to db"
    else
      render 'index', error: "failed to add usrp to db"
    end


  end

  #delete usrp entry from database
  def remove
    if Usrp.destroy(params[:id])
      redirect_to '/usrps', success: "USRP (id: '#{params['id']}') was removed from db."
    else
      render 'index', error: "failed to remove USRP."
    end
  end

  #create a new container with given usrp
  def create_container

  end

# to edit
  # private
  #   def usrp_params
  #     params.require(:usrp).permit(:ip, :model)
  #
  #   end

end

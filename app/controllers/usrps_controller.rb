class UsrpsController < ApplicationController


  def index
    require 'open3'
    @found_usrps = Hash.new

    @usrp = Usrp.new
    @usrps = Usrp.all

    # CHECK FOR DISCOVERY
    if !params[:discover].blank?
      begin
        @stdout, @stderr, @status = Open3.capture3('uhd_find_devices')

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

      rescue Errno::ENOENT
        redirect_to '/', error: "uhd is not installed on the system."
        return
      end
    end



    # CHECK IF PROBE
    if !params[:probe_ip].blank?
      begin
        puts "uhd_usrp_probe --arg=\"addr=#{params[:probe_ip]}\""
        @stdout_probe,@@stderr_probe, @status_probe = Open3.capture3("uhd_usrp_probe --arg=\"addr=#{params[:probe_ip]}\"")

        puts @stdout_probe, @stderr_probe, @status_probe


      rescue Errno::ENOENT
        redirect_to '/', error: "uhd is not installed on the system."
        return
      end

    end

  end

  #add discovered usrp to database
  def create
    if params[:usrp_ip].blank? # no entry
      redirect_to '/usrps', error: "the USRP ip selection is not valid."
      return
    elsif Usrp.find_by(ip: params[:usrp_ip]) # already in db?
      redirect_to usrps_path, error: "USRP with ip '#{params[:usrp_ip]}' is already in db."
      return
    else # then create usrp entry
      begin
        # check for more info with usrp probe
        @stdout_probe, @stderr_probe, @status_probe = Open3.capture3("uhd_usrp_probe --arg=\"addr=#{params[:usrp_ip]}\"")

        usrp_params = Hash.new

        @stdout_probe.each_line do |line|
          # new uhd device
          if line.include? 'Mboard'
            usrp_params[:model] = line.split[3]
            break
          end
        end

      rescue Errno::ENOENT
        redirect_to '/', error: "uhd is not installed on the system."
      end

      usrp_params[:ip] = params[:usrp_ip]
      usrp_params[:assigned] = '- free -'
      usrp_params[:status] = 'up'

      @usrp = Usrp.new(usrp_params)
      if @usrp.save
        redirect_to usrps_path(probe_ip: usrp_params[:ip]), success: "USRP '#{usrp_params[:ip]}' added to db."
      else
        render 'index', error: "failed to add USRP to db."
      end
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

  def free
    if usrpDB = Usrp.find(params[:id])
      usrpDB.assigned = '- free -'
      if usrpDB.save
        redirect_to '/usrps', success: "USRP (id: '#{params[:id]}') is now free."
      else
        redirect_to '/usrps', error: "failed to free USRP."
      end
    else
      redirect_to '/usrps', error: "failed to free USRP."
    end
  end

# to edit
  # private
  #   def usrp_params
  #     params.require(:usrp).permit(:ip, :model)
  #
  #   end

end

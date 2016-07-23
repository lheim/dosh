class UsrpsController < ApplicationController
  def index

    require 'open3'
    begin
      @stdout, @stdeerr, @status = Open3.capture3('uhd_find_devices')
    rescue Errno::ENOENT
      redirect_to '/', error: "uhd is not installed on the system."
    end

    @usrp = Usrp.new
    @usrps = Usrp.all

  end


  #check/discovery for new usrp
  def refresh

  end


  #add discovered usrp to database


  def create
    @usrp = Usrp.new(usrp_params)
    if @usrp.save
      redirect_to '/usrps', success: "usrp '#{usrp_params['ip']}' added to db"
    else
      render 'index', error: "failed to add usrp to db"
    end


  end

  #delete usrp entry from database
  def remove
    if Usrp.destroy(params[:id])
      redirect_to '/usrps', success: "usrp (id: '#{params['id']}') was removed from db."
    else
      render 'index', error: "failed to remove usrp."
    end
  end

  #create a new container with given usrp
  def create_container

  end

# to edit
  private
    def usrp_params
      params.require(:usrp).permit(:ip, :model)

    end

end

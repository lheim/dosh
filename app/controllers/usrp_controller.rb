class UsrpController < ApplicationController
  def index

    @stdout, @stdeerr, @status = Open3.capture3('uhd_find_devices')

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
      redirect_to '/usrp'
    else
      render 'new'
    end
  end

  #delete usrp entry from database
  def delete
  #  @usrp = 
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

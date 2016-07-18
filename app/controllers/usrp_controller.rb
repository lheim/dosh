class UsrpController < ApplicationController
  def index

    @stdout, @stdeerr, @status = Open3.capture3('uhd_find_devices')

  end


  #check for new usrp
  def refresh

  end


  #add discovered usrp to database
  def add

  end

  #delete usrp entry from database
  def delete

  end

  #create a new container with given usrp
  def create

  end

end

class UsrpController < ApplicationController
  def index

    @stdout, @stdeerr, @status = Open3.capture3('uhd_find_devices')





  end
end

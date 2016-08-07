class ImagesController < ApplicationController

  def index
    begin
      @images = Docker::Image.all
    rescue => error
      redirect_to '/error', error: "error: #{error}"
      return
    end
  end

  def pull

    puts params[:name]
    Thread.new do
      image = Docker::Image.create('fromImage' => params[:name])
    end

    redirect_to images_path, success: "image is being pulled. wait some minutes."
  end


  def show
    @image = Docker::Image.get(params[:id])
  end

  def remove
    @image = Docker::Image.get(params[:id])
    @image.remove(:force => true)

    redirect_to images_path, success: "image successfully removed."
  end

  def tag
    @image = Docker::Image.get(params[:id])
    puts params[:name]
    @image.tag('repo' => params[:name], 'force' => true)

    redirect_to image_path, success: "image successfully renamed"
  end



end

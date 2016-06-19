class ImagesController < ApplicationController

  def index
    @images = Docker::Image.all
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

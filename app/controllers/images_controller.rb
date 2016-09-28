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

    image_name =  params[:name]
    if !image_name.include? ":latest"
      image_name << ':latest'
    end

    Thread.new do
      begin
        image = Docker::Image.create('fromImage' => image_name)
        puts "Image #{image} was succesfully downloaded."
      rescue => error
        redirect_to '/error', error: "error: #{error}"
        return
      end
    end

    redirect_to images_path, success: "image is being pulled. wait some minutes."
  end


  def show
    begin
      @image = Docker::Image.get(params[:id])
    rescue => error
      redirect_to '/error', error: "error: #{error}"
      return
    end

    @containers = Docker::Container.all(:all => true)


    # puts @containers = Docker::Container.all(all: true, filters: { created: ["runnidngd"] }.to_json)

  end

  def remove
    begin
      @image = Docker::Image.get(params[:id])
      @image.remove # (:force => true)
      redirect_to images_path, success: "image successfully removed."
    rescue => error
      redirect_to '/error', error: "error: #{error}"
    end
  end

  def tag
    begin
      @image = Docker::Image.get(params[:id])
      puts params[:name]
      @image.tag('repo' => params[:name], 'force' => true)
      redirect_to image_path, success: "image successfully renamed"
    rescue => error
      redirect_to '/error', error: "error: #{error}"
    end
  end



end

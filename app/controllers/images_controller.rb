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
    if image_name.include? ":latest"
      puts 'CONTAINS DEFAULT TAG'
    else
      image_name << ':latest'
      puts "ADDED TAG :LATEST #{image_name}"
    end

    Thread.new do
      image = Docker::Image.create('fromImage' => image_name)
      puts "Image #{image} was succesfully downloaded."
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

class ImagesController < ApplicationController
  def index
    @images = Docker::Image.all
  end
end

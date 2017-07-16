class GalleriesController < ApplicationController
  def index
    @galleries = current_user.galleries.all
    @gallery = Gallery.new
  end

  def create
    @gallery = current_user.galleries.build(gallery_params)
    unless params[:pictures]
      flash.now[:alert] = t '.no_picture_error'
      render :index
      return
    end
    save_gallery
    redirect_to galleries_path
  end

  def destroy
    Gallery.find_by(id: params[:id]).destroy
    flash[:success] = t '.gallery_deleted'
    redirect_to galleries_path
  end

  private

  def gallery_params
    params.require(:gallery).permit(allow_params)
  end

  def allow_params
    %i[name description pictures]
  end

  def save_gallery
    if @gallery.save
      params[:pictures].each do |picture|
        @gallery.pictures.create(picture: picture)
      end
    else
      flash[:alert] = t '.no_save_error'
    end
  end
end

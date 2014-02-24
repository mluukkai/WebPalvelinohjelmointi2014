class PlacesController < ApplicationController
  def index
  end

  def show
    @place = BeermappingApi.find(params[:id],session[:previous_city] )
  end

  def search
    @places = BeermappingApi.places_in(params[:city])
    session[:previous_city] = params[:city]
    if @places.empty?
      redirect_to places_path, notice: "No locations in #{params[:city]}"
    else
      render :index
    end
  end
end
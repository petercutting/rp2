class GearthController < ApplicationController
  def index
    #puts 'index ' + params[:CENTRE].inspect
    @centre = params[:CENTRE].split(",")
    @bbox = params[:BBOX].split(",")

    respond_to do |format|
      #format.html # index.html.erb
      format.kml  # index.kml.builder
    end

  end

  def network_link
    #puts 'network_link ' + params.inspect
    respond_to do |format|
      #format.html # index.html.erb
      format.kml  # index.kml.builder
    end
  end

end

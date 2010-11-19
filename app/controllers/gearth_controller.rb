class GearthController < ApplicationController
  def index
    #puts 'index ' + params[:CENTRE].inspect
    @centre=["0","0"]
    @bbox=["0","0","0","0"]
    @centre = params[:CENTRE].split(",") unless params[:CENTRE].nil?
    @bbox = params[:BBOX].split(",") unless params[:BBOX].nil?

    #
      @ps=[]
    igcfs = Igcfile.find(:all)  # get files
    igcfs.each do |igcf|    # for each file
      igcps = igcf.igcpoint(:all, :order => 'seq_secs')   # get points
      igcps.each do |igcp|          # for each point
        @ps<<[igcp.dlat.to_s,igcp.dlon.to_s]         # push data to array
        #puts [igcp.dlat.to_s,igcp.dlon.to_s].inspect
      end
    end

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

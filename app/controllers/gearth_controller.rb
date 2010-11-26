class GearthController < ApplicationController
  RAD_PER_DEG = 0.017453293  #  PI/180
  RADIUS = 6371 * 1000


  def route
    puts 'index ' + params[:CENTRE].inspect
    @centre=["0","0"]
    @bbox=["0","0","0","0"]
    @centre = params[:CENTRE].split(",") unless params[:CENTRE].nil?
    @bbox = params[:BBOX].split(",") unless params[:BBOX].nil?

    #
    @ps=[]
    #puts "TEST" + params[:id]
    igcf = Igcfile.find(params[:id])

    igcps = igcf.igcpoint(:all, :order => 'seq_secs')   # get points
    igcps.each do |igcp|          # for each point
      @ps<<(igcp.rlon/RAD_PER_DEG).to_s + ',' + (igcp.rlat/RAD_PER_DEG).to_s + ',' + igcp.baro_alt.to_s + "\n"         # push data to array
    end
    respond_to do |format|
      #format.html # index.html.erb
      format.kml  # index.kml.builder
    end
  end

  def index
    puts 'index ' + params[:CENTRE].inspect
    @centre=["0","0"]
    @bbox=["0","0","0","0"]
    @centre = params[:CENTRE].split(",") unless params[:CENTRE].nil?
    @bbox = params[:BBOX].split(",") unless params[:BBOX].nil?

    #
    @ps=[]
    @igcfs = Igcfile.find(:all)  # get files
    @igcfs.each do |igcf|    # for each file
      igcps = igcf.igcpoint(:all, :order => 'seq_secs')   # get points
      igcps.each do |igcp|          # for each point
        @ps<<(igcp.rlon/RAD_PER_DEG).to_s + ',' + (igcp.rlat/RAD_PER_DEG).to_s + ',' + igcp.baro_alt.to_s + "\n"         # push data to array
        #@ps<<[igcp.dlat.to_s,igcp.dlon.to_s]         # push data to array
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

    @igcfs = Igcfile.find(:all)

    respond_to do |format|
      #format.html # index.html.erb
      format.kml  # index.kml.builder
    end
  end

end

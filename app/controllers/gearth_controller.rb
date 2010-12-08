class GearthController < ApplicationController

  include Igc
  require 'Constants'


  def network_link3
    #puts 'network_link3' + Constants::XX
    path = "public/data"
    path = params[:path] unless params[:path].nil?

    #puts 'path ' + path
    #puts 'p ' + Dir.pwd
    #puts 'network_link3 ' + params.inspect
    @entries = []

    # Cycle through directory
    Dir.foreach(path) do |e|
      entry = path + "/" + e

      if entry.last == "."
        #puts 'ignoring ' + entry
        next
      end

      puts entry.inspect
      if File.directory?(entry)
        #puts 'dir2 ' + entry
        @entries << entry
      end

      if File.file?(entry)
        if entry.downcase.match(".igc")
          #puts 'igc ' + entry
          @entries << entry
        end
      end
    end

    respond_to do |format|
      #format.html # index.html.erb
      format.kml  # index.kml.builder
    end
  end


  def route
    puts 'route ' + params[:path].inspect
    @centre=["0","0"]
    @bbox=["0","0","0","0"]
    @centre = params[:CENTRE].split(",") unless params[:CENTRE].nil?
    @bbox = params[:BBOX].split(",") unless params[:BBOX].nil?

    @objects=[]
    Igc.import_igcfile(params[:path],@objects)

    respond_to do |format|
      #format.html # index.html.erb
      format.kml  # index.kml.builder
    end
  end


  #################

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

end

class GearthController < ApplicationController
  require 'ruby-debug'

  include Igc
  require 'Constants'


  def network_link3
    #puts 'network_link3' + Constants::XX
    path = "public/data"
    path = "c:/Users/peter/workspace_rails/igcsmall"

    path = params[:path] unless params[:path].nil?

    #puts 'path ' + path
    #puts 'p ' + Dir.pwd
    puts 'network_link3 ' + params.inspect
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


  def thermals
    puts 'thermals '
    @centre=["0","0"]
    @bbox=["0","0","0","0"]
    @centre = params[:CENTRE].split(",") unless params[:CENTRE].nil?
    @bbox = params[:BBOX].split(",") unless params[:BBOX].nil?
    #debugger

    #path=params[:path]
    #@igcfile = Igcfile.find_by_filename(path.split("/").last)
    @windpoints = Windpoint.find(:all,:order => "seq_secs DESC" )
    @windpoints.each {|wp|
      wp[:dlon] = wp[:dlon] / Constants::RAD_PER_DEG
      wp[:dlat] = wp[:dlat] / Constants::RAD_PER_DEG
      wp[:dlon2] = wp[:dlon2] / Constants::RAD_PER_DEG
      wp[:dlat2] = wp[:dlat2] / Constants::RAD_PER_DEG
    }

    respond_to do |format|
      #format.html # index.html.erb
      format.kml  # index.kml.builder
    end
  end


  def thermals0
    puts 'thermals '
    @centre=["0","0"]
    @bbox=["0","0","0","0"]
    @centre = params[:CENTRE].split(",") unless params[:CENTRE].nil?
    @bbox = params[:BBOX].split(",") unless params[:BBOX].nil?
    #debugger

    #path=params[:path]
    #@igcfile = Igcfile.find_by_filename(path.split("/").last)
    @windpoints = Windpoint.find(:all,:order => "seq_secs DESC" )

    @windpoints.each {|wp|
      secs =  wp[:altitude] / wp[:climb]
      dis = secs * wp[:speed]
      d=dis/Constants::RADIUS

      lat0=Math.asin(Math.sin(wp[:dlat])*Math.cos(d)+Math.cos(wp[:dlat])*Math.sin(d)*Math.cos(wp[:direction]))
      if (Math.cos(lat0)==0)
        lon0=wp[:dlon]      # endpoint a pole
      else
        begin
#          puts
          lon0=(
          (wp[:dlon]-
              Math.asin(
                Math.sin(wp[:direction])*
                  Math.sin(d)/Math.cos(lat0)
                )+Constants::PI) % (2*Constants::PI))-Constants::PI
          rescue
          puts wp[:altitude].to_s
          puts wp[:climb].to_s
          puts secs.to_s
          puts dis.to_s
          puts "lat " + lat0.to_s
          puts "lon " + lon0.to_s
          puts wp[:dlon].to_s
          puts wp[:dlat].to_s
          puts wp[:direction].to_s
$stdout.flush
        end
      end
    wp[:lat0] = lat0 / Constants::RAD_PER_DEG
    wp[:lon0] = lon0 / Constants::RAD_PER_DEG
    wp[:dlat] = wp[:dlat] / Constants::RAD_PER_DEG
    wp[:dlon] = wp[:dlon] / Constants::RAD_PER_DEG
    }

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
    #debugger
    path=params[:path]
    filename=path.split("/").last

    #    Igcfile.destroy_all( ["filename = ?",filename])            # forces data reload

    @igcfile = Igcfile.get(path,Constants::PROC_VERSION.to_i)
    @igcfile.import_file(path)

    @igcfile.objects.each {|wp|
      wp[:malon] = wp[:malon] / Constants::RAD_PER_DEG
      wp[:malat] = wp[:malat] / Constants::RAD_PER_DEG
    }

    @windpoints = Windpoint.find(:all,:order => "seq_secs DESC",:conditions => {
      :igcfile_id  => @igcfile.id })

    @windpoints.each {|wp|
      wp[:dlon] = wp[:dlon] / Constants::RAD_PER_DEG
      wp[:dlat] = wp[:dlat] / Constants::RAD_PER_DEG
      wp[:dlon2] = wp[:dlon2] / Constants::RAD_PER_DEG
      wp[:dlat2] = wp[:dlat2] / Constants::RAD_PER_DEG

      dlon_diff=wp[:dlon]-@centre[0].to_f
      dlat_diff=wp[:dlat]-@centre[1].to_f

      wp[:dlon_centred]=wp[:dlon]-dlon_diff
      wp[:dlat_centred]=wp[:dlat]-dlat_diff
      wp[:dlon2_centred]=wp[:dlon2]-dlon_diff
      wp[:dlat2_centred]=wp[:dlat2]-dlat_diff
    }

    respond_to do |format|
      #format.html # index.html.erb
      format.kml  # index.kml.builder
    end
  end


  def index
    puts params.inspect
    @centre=["0","0"]
    @bbox=["0","0","0","0"]
    @centre = params[:CENTRE].split(",") unless params[:CENTRE].nil?
    @bbox = params[:BBOX].split(",") unless params[:BBOX].nil?

    #
    #    @ps=[]
    #    @igcfs = Igcfile.find(:all)  # get files
    #    @igcfs.each do |igcf|    # for each file
    #      igcps = igcf.igcpoint(:all, :order => 'seq_secs')   # get points
    #      igcps.each do |igcp|          # for each point
    #        @ps<<(igcp.rlon/RAD_PER_DEG).to_s + ',' + (igcp.rlat/RAD_PER_DEG).to_s + ',' + igcp.baro_alt.to_s + "\n"         # push data to array
    #        #@ps<<[igcp.dlat.to_s,igcp.dlon.to_s]         # push data to array
    #        #puts [igcp.dlat.to_s,igcp.dlon.to_s].inspect
    #      end
    #    end

    respond_to do |format|
      #format.html # index.html.erb
      format.kml  # index.kml.builder
    end
  end


  def network_link_crosshair
    puts params.inspect

    respond_to do |format|
      #format.html # index.html.erb
      format.kml  # index.kml.builder
    end
  end

  # http://localhost/gearth/crosshair?BBOX=11.19125746392158,57.2508102878951,21.11411106554142,61.86448638182706&CENTRE=16.29523674992932,59.58649967679079
  # http://localhost/gearth/crosshair?BBOX=16.56258229262255,58.39636918768792,26.30095886892859,63.19376486212607&CENTRE=16.99764635180972,60.04039534660431]
  # http://localhost/gearth/route?path=public%2Fdata%2F074C3X62.IGC&BBOX=16.82113707817681,58.8239660179952,24.31766488558778,62.48755262212542&CENTRE=17.04949172377386,60.02571428479256

  def crosshair
    puts params.inspect
    @centre=["0","0"]
    @bbox=["0","0","0","0"]
    @centre = params[:CENTRE].split(",") unless params[:CENTRE].nil?
    @bbox = params[:BBOX].split(",") unless params[:BBOX].nil?
    #puts "bbox " + @bbox.inspect

    respond_to do |format|
      #format.html # index.html.erb
      format.kml  # index.kml.builder
    end
  end


  def plot
    puts 'plot ' + params.inspect
    @centre=["0","0"]
    @bbox=["0","0","0","0"]
    @centre = params[:CENTRE].split(",") unless params[:CENTRE].nil?
    @bbox = params[:BBOX].split(",") unless params[:BBOX].nil?
    #debugger

    #    Po.destroy_all( ["filename = ?",filename])            # forces data reload
    #    Po.destroy_all( )            # forces data reload

    @pos = Po.find(:all,:order => "time DESC", :limit =>25,:conditions => { })

#        @pos.each {|wp|
#          wp[:longitude] = wp[:longitude] / Constants::RAD_PER_DEG
#          wp[:latitude] = wp[:latitude] / Constants::RAD_PER_DEG
#        }

    @po = @pos[0]
    respond_to do |format|
      #format.html # index.html.erb
      format.kml  # index.kml.builder
    end
  end

end

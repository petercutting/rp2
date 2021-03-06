class GearthController < ApplicationController
  require 'ruby-debug'

  include Igc
  require 'Constants'

  def common_substring(data)
    data.inject { |m, s| s[0,(0..m.length).find { |i| m[i] != s[i] }.to_i] }
  end


  def update_substr(a,s)
    a.each_with_index do |e,i|
      if (f=substr(e,s))>0
        a[i]=e[0..f]
        return
      end
    end
    a.push s
  end


  def substr(a,b)
    f=0
    for i in 0..[a.length,b.length].min-1
      if a[i]==b[i]
        f=i
      else
        return f
      end
    end
    return f
  end

  #  def trim_to_dir_sep(p)
  #    while p[p.length]=="/" do
  #      p = p[0..p.length-1]
  #      puts p
  #    end
  #  end



  def trim_to_dir_sep(p)
    l=p.length
    while l>0 do
      #puts p[l].chr
      if p[l-1].chr==File::SEPARATOR or p[l-1].chr==File::ALT_SEPARATOR
        return p[0...l]
      end
      l=l-1
    end
  end


  #http://localhost:3000/gearth/network_link3?path=public/data

  def network_link3
    puts 'network_link3 ' + params.inspect
    @entries = []
    #puts 'network_link3'
    #    path = "public/data"
    #    path = "c:/Users/peter/workspace_rails/igcsmall"

    path = params[:path] unless params[:path].nil?

    roots = []
    if params[:path].nil?
      @igcfs = Igcfile.find(:all, :order => 'path')  # get files
      @igcfs.each do |igcf|    # for each file
        #puts igcf.path
        update_substr(roots ,igcf.path)
      end
      puts roots.inspect

      $stdout.flush
      roots.each do |r|
        @entries << trim_to_dir_sep(r)
      end
    end
    puts 'a'

    puts @entries.inspect

    if not params[:path].nil?
      #puts 'path ' + path
      #puts 'p ' + Dir.pwd

      # Cycle through directory
      Dir.foreach(path) do |e|
        entry = path + "/" + e
        #puts entry.inspect

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
    end


    respond_to do |format|
      #format.html # index.html.erb
      format.kml  # index.kml.builder
    end
  end


  def igc
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


  def thermal_dirs
    spread = 20
    seg_i = 360 / spread
    @dirs=[]
     (0..seg_i-1).each {|s|
      dir = {:dir => (s*spread),:spread => spread}
      @dirs << dir
    }

    respond_to do |format|
      #format.html # index.html.erb
      format.kml  # index.kml.builder
    end
  end


  def thermals
    @centre=["0","0"]
    @bbox=["0","0","0","0"]
    @centre = params[:CENTRE].split(",") unless params[:CENTRE].nil?
    @bbox = params[:BBOX].split(",") unless params[:BBOX].nil?
    #debugger

    dir=0
    dir = params[:dir].to_i unless params[:dir].nil?
    spread=20 # default
    spread = params[:spread].to_i unless params[:spread].nil?

    puts 'thermals ' + dir.to_s + " " + spread.to_s

    from_rad = (dir - spread/2) * Constants::RAD_PER_DEG
    if from_rad < 0.0
      from_rad = from_rad + (Constants::PI * 2.0)
    end

    to_rad = (dir + spread/2) * Constants::RAD_PER_DEG
    if to_rad < 0.0
      to_rad = to_rad + (Constants::PI * 2.0)
    end

    if from_rad < to_rad
      @windpoints = Windpoint.find(:all, :order => "seq_secs DESC",
      :conditions => [ "direction >= ? AND direction < ?",  from_rad, to_rad]  )
    else
      @windpoints1 = Windpoint.find(:all, :order => "seq_secs DESC",
      :conditions => [ "direction >= ? AND direction < ?",  from_rad, 0.0]  )

      @windpoints = Windpoint.find(:all, :order => "seq_secs DESC",
      :conditions => [ "direction >= ? AND direction < ?",  0.0, to_rad]  )

      @windpoints = @windpoints + @windpoints1
    end

    @thermal_sources=[]

    @windpoints.each {|wp|

    reverse=(wp[:direction] + Constants::PI) % (2*Constants::PI)
    #reverse=(wp[:direction] ) % (2*Constants::PI)

      secs =  wp[:altitude] / wp[:climb]
      dis = secs * wp[:speed]
      d=dis/Constants::RADIUS
      lat0=Math.asin(Math.sin(wp[:dlat])*Math.cos(d)+Math.cos(wp[:dlat])*Math.sin(d)*Math.cos(reverse))
      if (Math.cos(lat0)==0)
        lon0=wp[:dlon]      # endpoint a pole
      else
        begin
          #          puts
#          lon0=(
#           (wp[:dlon]-
#           Math.asin( Math.sin(reverse)* Math.sin(d)/Math.cos(lat0))+Constants::PI) % (2*Constants::PI))-Constants::PI
#          lon0=(
#           (wp[:dlon]+
#           Math.atan2( Math.cos(d) - Math.sin(wp[:dlat])*Math.sin(lat0),Math.cos(d)-Math.sin(wp[:dlat])*Math.sin(lat0))
#           ))

          lont=(
           Math.atan2( Math.sin(reverse) * Math.sin(d) * Math.cos(wp[:dlat]) , Math.cos(d)-Math.sin(wp[:dlat])*Math.sin(lat0))
           )

           lon0=((wp[:dlon]- lont + Constants::PI) % (2*Constants::PI))-Constants::PI

          rescue
        end
      end

      thermal_source={:lat0 => lat0 / Constants::RAD_PER_DEG, :lon0 => lon0 / Constants::RAD_PER_DEG, :altitude0 => 0.0,
        :lat1=>wp[:dlat] / Constants::RAD_PER_DEG, :lon1 => wp[:dlon] / Constants::RAD_PER_DEG, :altitude1 => wp[:altitude]}
        @thermal_sources << thermal_source

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

    puts 'centre0 ' + @centre[0].to_f.to_s
    puts 'centre1 ' + @centre[1].to_f.to_s

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

      #      dlon_diff=wp[:dlon]-(@centre[0].to_f / Constants::RAD_PER_DEG)
      #      dlat_diff=wp[:dlat]-(@centre[1].to_f / Constants::RAD_PER_DEG)
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


  def top
    puts 'top ' + params.inspect

    @path = params[:path]

    respond_to do |format|
      #format.html # index.html.erb
      format.kml  # index.kml.builder
    end
  end

  def process_igc_files
    puts __method__.to_s + ' ' + params.inspect

    #@path = params[:path]
    call_rake :ligc3, ["params[:path]",0]


    respond_to do |format|
      #format.html # index.html.erb
      format.kml  # index.kml.builder
    end
  end

end

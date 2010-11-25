desc "Loads IGC files from specified directory (or .)"

task :ligc2, [:dir] => :environment do |t, args|
  args.with_defaults(:dir => "public/data")

  require 'ar-extensions'
  require 'ar-extensions/import/mysql'

  #gem install activerecord-import -v 0.2.0
  # rake task?

  RAD_PER_DEG = 0.017453293  #  PI/180
  RADIUS = 6371 * 1000
  GRAV_CONST = 9.81
  GLIDER_MASS = 450



  #http://users.ox.ac.uk/~gliding/docs/Polar%20Comparison%20Chart.xls
  # LS4 40KG/m2
  #  polar_sink_ms = [0.80,0.71,0.69,0.69,0.69,0.72,0.75,0.79,0.86,0.91,0.98,1.05,1.12,1.20,1.29,1.38,1.49,1.62,1.76,1.91,2.08,2.27,2.48,2.69]
  #  polar_speed_kmh = [80,85,90,95,100,105,110,115,120,125,130,135,140,145,150,155,160,165,170,175,180,185,190,195]
  #  polar_speed_ms = polar_speed_kmh.collect{|x| eval(sprintf("%2.1f",x/3.6))}
  #  polar_speed_ms2 = polar_speed_kmh.collect{|x| eval(sprintf("%2.0f",x/3.6))}
  #  #puts polar_speed_ms.inspect
  #  #puts polar_speed_ms2.inspect



  puts File.dirname(__FILE__)
  #  @dir="#{args.dir}"
  #  puts @dir

  class Import
    #objects = Array.new
    Polar_sink = Array.new

    def interpolate_polar
      polar_sink_in_ms = [0.80,0.71,0.69,0.69,0.69,0.72,0.75,0.79,0.86,0.91,0.98,1.05,1.12,1.20,1.29,1.38,1.49,1.62,1.76,1.91,2.08,2.27,2.48,2.69]
      polar_speed_in_kmh = [80,85,90,95,100,105,110,115,120,125,130,135,140,145,150,155,160,165,170,175,180,185,190,195]
      polar_speed_in_ms = polar_speed_in_kmh.collect{|x| eval(sprintf("%2.0f",x/3.6))}
      #puts polar_speed_in_ms.inspect

      Polar_sink.clear

       (0..80).each {|speed|                                                       # meters per second
        x = polar_speed_in_ms.find_all{|item| item >= speed }.first
        x = polar_speed_in_ms.find_all{|item| item <= speed }.last if x.nil?
        Polar_sink << polar_sink_in_ms[ polar_speed_in_ms.index(x) ]
      }

      #puts Polar_sink.inspect
    end

    def import_igcfiles(dir)
      num_recs=0

      Igcfile.delete_all
      Igcpoint.delete_all

      @files = Dir.entries(dir)
      for file in @files
        if file != "." && file != ".."
          if file.to_s.downcase.match(".igc")
            #          start = Time.now
            num_recs = import_a_igcfile(dir + "/" + file.to_s)
            #          secs =  Time.now - start
            #          puts file.to_s + ' ' + num_recs.to_s + ' ' + (num_recs/secs).to_i.to_s
            #          STDOUT.flush
          end
        end

      end
    end


    #http://www.gliding.ch/images/news/lx20/fichiers_igc.htm#Brec
    #B0915235535648N01340869EA-006900049000
    #B0915355535648N01340870EA-007000049000
    #B091547 5535648 N 01340870 E A-007000049000

    #B103422 5535706N 01340750E A0003200037000016000000
    #B1034245535706N01340750EA0003100037000016000000
    #B1034265535706N01340750EA0003100037000012000000
    #B1038255535669N01339604EA0039000396000996000000

    # relative X Y movement ENL curveing
    def import_a_igcfile(file)

      columns = [ :lat_lon, :baro_alt, :gps_alt, :enl, :seq_secs, :igcfile_id, :rlat, :rlon, :x, :y]
      options = { :validate => false }
      line_save=""

      sma=[]

      objects = []
      num_recs=1 # to prevent divide by zero
      counter=0

      begin
        igcfile = Igcfile.new()
        igcfile.filename=file
        igcfile.save!
        rescue
        next
      end

      start = Time.now

      # I033638FXA3941ENL4247REX        an I record defines B record extensions
      counter=0
      time=0
      fp = File.open(file, "r")
      contents = fp.read

      # get I record
      b_extensions2 = Hash.new
      contents.each_line do |line|
        a=line.unpack('a1a2a7a7a7a7a7a7a7') # hopefully enough
        if a[0]=='A'
          next
        end
        if a[0]=='H'
          next
        end
        if a[0]=='I'
          if not a[1].nil?
            0.upto(a[1].to_i){|n|
              b=a[n+2].unpack('a2a2a3')
              b_extensions2[b[2]]={:start => b[0], :finnish => b[1]}
            }
          end
          break
        end
        break
      end

      if b_extensions2.length == 0
        puts 'No I record'
      end

      if b_extensions2['ENL'].nil?
        puts 'No ENL in I record'
      else
        #      puts b_extensions2['ENL'].inspect
      end

      #    last_time=0
      contents.each_line do |line|
        # 0(1)=rec, 1(6)=time, 2(8)=lat, 3(9)=lon, 4(1)=validity, 5(5)=baro_alt, 6(5)=gps_alt
        # optional see Irec  7(3)=fix_accuracy, 8(2)=num_satelites, 9(3)=enl
        line_save=line


        a=line.unpack('a1a6a8a9a1a5a5a')
        if a[0].to_s == 'B'

          num_recs=num_recs+1

          # time B0915235535648N01340869EA-006900049000
          h,m,s = a[1].scan(%r{(\d{2})(\d{2})(\d{2})}).flatten
          time = h.to_i * 3600 + m.to_i * 60  + s.to_i
          #        if last_time==0
          #          last_time=time
          #        end

          # enl
          if hv=b_extensions2['ENL']
            enl=line[hv[:start].to_i..hv[:finnish].to_i]
          else
            enl='0'
          end

          dd,mm,mmm,ns = a[2].scan(%r{(\d{2})(\d{2})(\d{3})(\w{1})}).flatten    #Latitude DDMMMMMN Valid characters N, S, 0-9
          rlat = ((dd.to_f + mm.to_f/60 + (mmm.to_f/1000)/60))*RAD_PER_DEG
          rlat = - rlat unless ns=='N'

          ddd,mm,mmm,ew = a[3].scan(%r{(\d{3})(\d{2})(\d{3})(\w{1})}).flatten   #Longitude DDDMMMMME Valid characters E,W, 0-9
          rlon = ((ddd.to_f + mm.to_f/60 + (mmm.to_f/1000)/60))*RAD_PER_DEG
          rlon = - rlon unless ew=='E'

          # cartesian
          x = RADIUS * Math.cos(rlat) * Math.cos(rlon)
          y = RADIUS * Math.cos(rlat) * Math.sin(rlon)

          #columns = [ :lat_lon, :baro_alt, :gps_alt, :enl, :seq_secs, :igcfile_id, :rlat, :rlon, :x, :y]
          #objects << [ a[2]+','+a[3],a[5].to_i,a[6].to_i,enl.to_i, time, igcfile.id,rlat,rlon,x.to_i,y.to_i]
          obj = { :lat_lon => a[2]+','+a[3],:baro_alt => a[5].to_i, :gps_alt => a[6].to_i,
            :enl => enl.to_i, :seq_secs=> time, :igcfile_id => igcfile.id, :rlat => rlat, :rlon=>rlon,
            :x => x.to_i, :y=> y.to_i}

          #speed
          obj[:ms]=0
          objects.reverse_each {|item|
            obj[:ms] = (((obj[:x] - item[:x])**2 + (obj[:y] - item[:y])**2)**0.5)/(obj[:seq_secs] - item[:seq_secs]).to_i
            break
          }

          #moving average speed in 2 dimnsions
          max=0
          may=0
          avg_cnt=0
          objects.reverse_each {|item|
            break if item[:seq_secs] > obj[:seq_secs]-40
            avg_cnt+=1
            max=max+item[:x]
            may=may+item[:y]
          }

          if avg_cnt > 0
            obj[:max]=(max/avg_cnt).to_i
            obj[:may]=(may/avg_cnt).to_i
            obj[:mams] = (((obj[:max] - item[:max])**2 + (obj[:may] - item[:may])**2)**0.5)/(obj[:seq_secs] -item[:seq_secs]).to_i
          else
            obj[:mams]=0
            #obj[:max]=obj[:x]
            #obj[:may]=obj[:y]
          end

          # energy change
          obj[:pe] = GLIDER_MASS * GRAV_CONST * obj[:baro_alt]   # mass is a guess
          obj[:ke] = 0.5 * GLIDER_MASS * (obj[:ms])**2             # should compensate speed for wind component here
          obj[:te]= obj[:pe] + obj[:ke]
          ##obj[:dedt]=((obj[:pe] - save_obj[:pe]) + (obj[:ke] - save_obj[:ke])) / (obj[:seq_secs] - save_obj[:seq_secs])

          save_obj=obj if save_obj.nil?

          obj[:dedt]=((obj[:te] - save_obj[:te]) + (obj[:te] - save_obj[:te])) / (obj[:seq_secs] - save_obj[:seq_secs])

          objects << obj
          save_obj=obj

          # the import bogs down if there are too many records so chop it up
          counter=counter+1
          #          if counter > 100
          #            Igcpoint.import(columns, objects, options)
          #            objects=[]
          #            counter=0
          #          end
        end
      end

      #
      objects.each_with_index do |object,index|

        avg_cnt=0
        objects[0..index].reverse_each {|item|
          break if item[:seq_secs] < object[:seq_secs]-40
          avg_cnt+=1

          #          te = (object[:te] - save_obj[:te]) unless save_obj[:te].nil?
          #          tt = (object[:seq_secs] - save_obj[:seq_secs]) unless save_obj[:seq_secs].nil?
          #          dedt = te/tt - ()

          #            max=max+item[:x]
          #            may=may+item[:y]
        }

        #          if avg_cnt > 0
        #            obj[:max]=(max/avg_cnt).to_i
        #            obj[:may]=(may/avg_cnt).to_i
        #            obj[:mams] = (((obj[:max] - item[:max])**2 + (obj[:may] - item[:may])**2)**0.5)/(obj[:seq_secs] -item[:seq_secs]).to_i
        #          else
        #            obj[:mams]=0
        #            #obj[:max]=obj[:x]
        #            #obj[:may]=obj[:y]
        #          end

      end


      #Igcpoint.import(columns, objects, options) unless objects.length==0
      secs =  Time.now - start
      puts file.to_s + ' ' + num_recs.to_s + ' ' + (num_recs/secs).to_i.to_s
      STDOUT.flush

      fp.close
      num_recs
    end

    #http://www.chem.uoa.gr/applets/appletsmooth/appl_smooth2.html
    #Savitzky-Golay
    #My next fallback would be least squares fit. A Kalman filter will smooth the data taking velocities into account,
    #whereas a least squares fit approach will just use positional information. Still, it is definitely simpler to implement
    #and understand. It looks like the GNU Scientific Library may have an implementation of this.

    #Another algorithm to consider is the Ramer-Douglas-Peucker line simplification algorithm,
    #it is quite commonly used in the simplification of GPS data.
    #(http://en.wikipedia.org/wiki/Ramer-Douglas-Peucker_algorithm)
    #
    #  sql = <<SQL
    #
    #    insert into igcfile values ( 'one' );
    #
    #  SQL
    #
    #  db.execute_batch( sql )
    #

  end
  #my $x = cos($lat) * cos($lon); my $y = cos($lat) * sin($lon)

  def haversine_distance( lat1, lon1, lat2, lon2 )

    dlon = lon2 - lon1
    dlat = lat2 - lat1

    dlon_rad = dlon * RAD_PER_DEG
    dlat_rad = dlat * RAD_PER_DEG

    lat1_rad = lat1 * RAD_PER_DEG
    lon1_rad = lon1 * RAD_PER_DEG

    lat2_rad = lat2 * RAD_PER_DEG
    lon2_rad = lon2 * RAD_PER_DEG

    # puts "dlon: #{dlon}, dlon_rad: #{dlon_rad}, dlat: #{dlat}, dlat_rad: #{dlat_rad}"

    a = Math.sin((lat2 - lat1)/2)**2 + Math.cos(lat1) * Math.cos(lat2) * Math.sin((lon2 - lon1)/2)**2
    #a = Math.sin(dlat_rad/2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad/2)**2
    c = 2 * Math.asin( Math.sqrt(a))

    RADIUS * c     # delta in meters

    @distances["m"] = dMeters
  end






  puts "Starting..."

  import = Import.new
  import.interpolate_polar()
  import.import_igcfiles("#{args.dir}")

end

#[1, 2, 3, 4].inject(0) { |result, element| result + element } # => 10

#[1, 2, 3, 4, 5, 6].select { |element| element % 2 == 0 }.collect { |element| element.to_s } # => ["2", "4", "6"]

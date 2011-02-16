class Igcfile < ActiveRecord::Base
  has_many :igcpoint, :dependent => :destroy
  has_many :windpoint, :dependent => :destroy

  require 'ruby-debug'

  attr_accessor :objects
  attr_accessor :wind_points


  def after_initialize
    # after_initialize seems to be necessary since activerecord doesnt always call initialize
    self.objects=[]
  end



  def Igcfile.get(path,proc_version)
    #debugger

    begin
            filename=path.split("/").last

      puts "Looking in DB for " + filename
      @igcfile = Igcfile.find_by_filename!(filename) # ! enables a recordnotfound exception

      if @igcfile.proc_version.to_i < proc_version
        puts "Old version " + @igcfile.proc_version.to_s
        raise ActiveRecord::RecordNotFound
      end

      rescue ActiveRecord::RecordNotFound => ex
      #puts ex.message
      #puts ex.backtrace.join("\n")
      Igcfile.destroy_all( ["filename = ?",filename])
      @igcfile = Igcfile.new(:path => path, :filename => filename, :proc_version => proc_version)
      @igcfile.save

      #        @windpoints = Windpoint.find(:all,:order => "seq_secs DESC",:conditions => {
      #          :igcfile_id  => @igcfile.id })

      rescue Exception => ex
      puts "Generic " + ex.message
    end

    @igcfile.import_file(path)
    Windpoint.find_thermals(@igcfile)

    @igcfile
  end



  def import_file(path)
    #puts 'import'

    save_obj=Hash.new
    num_recs=1 # to prevent divide by zero
    counter=0

    objects=[]

    #puts "opening file " + path
    fp = File.open(path, "r")
    contents = fp.read
    fp.close()
    #debugger
    # get I record
    # I033638FXA3941ENL4247REX        an I record defines B record extensions
    b_extensions2 = Hash.new
    contents.each_line do |line|
      a=line.unpack('a1a2a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7') # hopefully enough
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
      #puts 'No I record'
    end

    if b_extensions2['ENL'].nil?
      #puts 'No ENL in I record'
    else
      #puts b_extensions2['ENL'].inspect
    end

    #    contents.each_byte {|x|
    #      puts x.to_s + " " + x.to_i.to_s
    #    }

    contents.each_line do |line|
      #puts line +"XX"
      #      if line.match("B1216027500439")
      #        debugger
      #      end
      # 0(1)=rec, 1(6)=time, 2(8)=lat, 3(9)=lon, 4(1)=validity, 5(5)=baro_alt, 6(5)=gps_alt
      # optional see Irec  7(3)=fix_accuracy, 8(2)=num_satelites, 9(3)=enl

      a=line.unpack('a1a6a8a9a1a5a5a')
      if a[0].to_s == 'B'               # only interested in B records

        num_recs=num_recs+1

        # time B0915235535648N01340869EA-006900049000
        h,m,s = a[1].scan(%r{(\d{2})(\d{2})(\d{2})}).flatten
        seq_secs = h.to_i * 3600 + m.to_i * 60  + s.to_i
        #puts a[1].to_s

        # enl
        if hv=b_extensions2['ENL']
          enl=line[hv[:start].to_i..hv[:finnish].to_i]
        else
          enl='0'
        end

        #lat
        dd,mm,mmm,ns = a[2].scan(%r{(\d{2})(\d{2})(\d{3})(\w{1})}).flatten    #Latitude DDMMMMMN Valid characters N, S, 0-9
        dlat = ((dd.to_f + mm.to_f/60 + (mmm.to_f/1000)/60))
        dlat = - dlat unless ns=='N'
        rlat = dlat*Constants::RAD_PER_DEG

        #lon
        ddd,mm,mmm,ew = a[3].scan(%r{(\d{3})(\d{2})(\d{3})(\w{1})}).flatten   #Longitude DDDMMMMME Valid characters E,W, 0-9
        dlon = ((ddd.to_f + mm.to_f/60 + (mmm.to_f/1000)/60))
        dlon = - dlon unless ew=='E'
        rlon = dlon*Constants::RAD_PER_DEG
        #debugger
        # cartesian
        x = (Constants::RADIUS * Math.cos(rlat) * Math.cos(rlon)).to_i
        y = (Constants::RADIUS * Math.cos(rlat) * Math.sin(rlon)).to_i
        z = ((Constants::RADIUS ) * Math.sin(rlat))

        obj = { :lat_lon => a[2]+','+a[3], :baro_alt => a[5].to_i, :gps_alt => a[6].to_i,
          :enl => enl.to_i, :seq_secs => seq_secs, :rlat => rlat, :rlon => rlon,
          :dlat => dlat, :dlon => dlon,:x => x, :y => y, :z => z}

        if not save_obj.empty?
          # ignore duplicate records (It happens!)
          if obj[:seq_secs] == save_obj[:seq_secs]
            #puts "dup time " + line
            next
          end

          #speed
          obj[:ms] = (((obj[:x] - save_obj[:x])**2 + (obj[:y] - save_obj[:y])**2)**0.5)/(obj[:seq_secs] - save_obj[:seq_secs])

          # discard any crazy values (which happen!)
          if obj[:ms].abs==0.0 || obj[:ms].abs>150
            save_obj={}
            #puts "ignore " + line
            next
          end

          # energy change
          #obj[:pe] = Constants::GLIDER_MASS * Constants::GRAV_CONST * (obj[:baro_alt] )
          obj[:pe] = Constants::GLIDER_MASS * Constants::GRAV_CONST * (obj[:baro_alt] + $polar_sink[obj[:ms]] * (obj[:seq_secs] - save_obj[:seq_secs]))
          obj[:ke] = 0.5 * Constants::GLIDER_MASS * (obj[:ms])**2             # should compensate speed for wind component here

          obj[:dedt]=((obj[:pe] - save_obj[:pe]) + (obj[:ke] - save_obj[:ke])) / (obj[:seq_secs] - save_obj[:seq_secs])

          #moving average speed in 2 dimensions
          max=0
          may=0
          maz=0
          avg_cnt=0
          objects.reverse_each {|item|
            break if item[:seq_secs] < obj[:seq_secs]-30
            avg_cnt+=1
            max=max+item[:x]
            may=may+item[:y]
            maz=maz+item[:z]
          }

          if avg_cnt > 0
            obj[:max]=(max/avg_cnt).to_i
            obj[:may]=(may/avg_cnt).to_i
            obj[:maz]=(maz/avg_cnt).to_i
          else
            obj[:max]=obj[:x]
            obj[:may]=obj[:y]
            obj[:maz]=obj[:z]
          end

          # convert moving average back to decimal coordinates
          obj[:malat] = (Math.asin(obj[:maz].to_f / Constants::RADIUS) ) /Constants::RAD_PER_DEG
          obj[:malon] = (Math.atan2(obj[:may], obj[:max]) ) /Constants::RAD_PER_DEG

          obj[:mams] = (((obj[:max] - save_obj[:max])**2 + (obj[:may] - save_obj[:may])**2)**0.5)/(obj[:seq_secs] - save_obj[:seq_secs]).to_i

          objects << obj

        else
          obj[:ms]=0
          obj[:pe]=0
          obj[:ke]=0
          obj[:max]=obj[:x]
          obj[:may]=obj[:y]
          obj[:maz]=obj[:z]
        end

        save_obj=obj.dup
      end
    end
    #puts "count " + objects.count.to_s
    objects
  end

end

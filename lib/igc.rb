module Igc

  RAD_PER_DEG = 0.017453293  #  PI/180
  RADIUS = 6371 * 1000
  GRAV_CONST = 9.81
  GLIDER_MASS = 450


  def Igc.find_thermals(path,objects)

    objects.each_with_index do |object,index|

    end

    #
    #    objects.each_with_index do |object,index|
    #
    #      avg_cnt=0
    #      objects[0..index].reverse_each {|item|
    #        break if item[:seq_secs] < object[:seq_secs]-40
    #        avg_cnt+=1
    #
    #        #          te = (object[:te] - save_obj[:te]) unless save_obj[:te].nil?
    #        #          tt = (object[:seq_secs] - save_obj[:seq_secs]) unless save_obj[:seq_secs].nil?
    #        #          dedt = te/tt - ()
    #
    #        #            max=max+item[:x]
    #        #            may=may+item[:y]
    #      }
    #
    #      #          if avg_cnt > 0
    #      #            obj[:max]=(max/avg_cnt).to_i
    #      #            obj[:may]=(may/avg_cnt).to_i
    #      #            obj[:mams] = (((obj[:max] - item[:max])**2 + (obj[:may] - item[:may])**2)**0.5)/(obj[:seq_secs] -item[:seq_secs]).to_i
    #      #          else
    #      #            obj[:mams]=0
    #      #            #obj[:max]=obj[:x]
    #      #            #obj[:may]=obj[:y]
    #      #          end
    #      # the import bogs down if there are too many records so chop it up
    #      counter=counter+1
    #      #        if counter > 100
    #      #          Igcpoint.import(columns, objects, options)
    #      #          objects=[]
    #      #          counter=0
    #      #        end
    #    end

  end

  def Igc.import_igcfile(path,objects)

    #puts 'import_igcfile'
    save_obj=Hash.new
    num_recs=1 # to prevent divide by zero
    counter=0
    start = Time.now
    counter=0
    time=0

    fp = File.open(path, "r")
    contents = fp.read
    fp.close()

    # get I record
    # I033638FXA3941ENL4247REX        an I record defines B record extensions
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

    contents.each_line do |line|
      # 0(1)=rec, 1(6)=time, 2(8)=lat, 3(9)=lon, 4(1)=validity, 5(5)=baro_alt, 6(5)=gps_alt
      # optional see Irec  7(3)=fix_accuracy, 8(2)=num_satelites, 9(3)=enl

      a=line.unpack('a1a6a8a9a1a5a5a')
      if a[0].to_s == 'B'               # only interested in B records

        num_recs=num_recs+1

        # time B0915235535648N01340869EA-006900049000
        h,m,s = a[1].scan(%r{(\d{2})(\d{2})(\d{2})}).flatten
        time = h.to_i * 3600 + m.to_i * 60  + s.to_i

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

        # cartesian
        x = (RADIUS * Math.cos(rlat) * Math.cos(rlon)).to_i
        y = (RADIUS * Math.cos(rlat) * Math.sin(rlon)).to_i

        obj = { :lat_lon => a[2]+','+a[3], :baro_alt => a[5].to_i, :gps_alt => a[6].to_i,
          :enl => enl.to_i, :seq_secs => time, :rlat => rlat, :rlon => rlon,
          :dlat => dlat, :dlon => dlon,:x => x, :y => y}

        if not save_obj.empty?
          #speed
          obj[:ms] = (((obj[:x] - save_obj[:x])**2 + (obj[:y] - save_obj[:y])**2)**0.5)/(obj[:seq_secs] - save_obj[:seq_secs])

          # energy change
          #obj[:pe] = Constants::GLIDER_MASS * Constants::GRAV_CONST * (obj[:baro_alt] )
          obj[:pe] = GLIDER_MASS * GRAV_CONST * (obj[:baro_alt] + $polar_sink[obj[:ms]] * (obj[:seq_secs] - save_obj[:seq_secs]))
          obj[:ke] = 0.5 * Constants::GLIDER_MASS * (obj[:ms])**2             # should compensate speed for wind component here

          obj[:dedt]=((obj[:pe] - save_obj[:pe]) + (obj[:ke] - save_obj[:ke])) / (obj[:seq_secs] - save_obj[:seq_secs])

          #moving average speed in 2 dimnsions. could be moved out of this loop
          max=0
          may=0
          avg_cnt=0
          objects.reverse_each {|item|
            break if item[:seq_secs] < obj[:seq_secs]-30
            avg_cnt+=1
            max=max+item[:x]
            may=may+item[:y]
          }

          if avg_cnt > 0
            obj[:max]=(max/avg_cnt).to_i
            obj[:may]=(may/avg_cnt).to_i
          else
            obj[:max]=obj[:x]
            obj[:may]=obj[:y]
          end

          obj[:mams] = (((obj[:max] - save_obj[:max])**2 + (obj[:may] - save_obj[:may])**2)**0.5)/(obj[:seq_secs] - save_obj[:seq_secs]).to_i

          objects << obj

        else
          obj[:ms]=0
          obj[:pe]=0
          obj[:ke]=0
          obj[:max]=obj[:x]
          obj[:may]=obj[:y]
        end

        save_obj=obj
      end
    end

    #Igcpoint.import(columns, ary, options) unless ary.length==0
    secs =  Time.now - start
    puts path.to_s + ' ' + num_recs.to_s + ' ' + (num_recs/secs).to_i.to_s
    STDOUT.flush

    num_recs
  end


  def Igc.interpolate_polar()
    #http://users.ox.ac.uk/~gliding/docs/Polar%20Comparison%20Chart.xls
    # LS4 40KG/m2

    polar_sink = []
    polar_sink_in_ms = [0.80,0.71,0.69,0.69,0.69,0.72,0.75,0.79,0.86,0.91,0.98,1.05,1.12,1.20,1.29,1.38,1.49,1.62,1.76,1.91,2.08,2.27,2.48,2.69]
    polar_speed_in_kmh = [80,85,90,95,100,105,110,115,120,125,130,135,140,145,150,155,160,165,170,175,180,185,190,195]
    polar_speed_in_ms = polar_speed_in_kmh.collect{|x| eval(sprintf("%2.0f",x/3.6))}
    #puts polar_speed_in_ms.inspect

    polar_sink.clear

     (0..80).each {|speed|                                                       # meters per second
      x = polar_speed_in_ms.find_all{|item| item >= speed }.first
      x = polar_speed_in_ms.find_all{|item| item <= speed }.last if x.nil?
      polar_sink << polar_sink_in_ms[ polar_speed_in_ms.index(x) ]
    }

    #puts polar_sink.inspect
    polar_sink
  end

end

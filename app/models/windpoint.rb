class Windpoint < ActiveRecord::Base
  belongs_to :igcfile

  def Windpoint.find_thermals(igcfile)
    puts "Windpoint.find_thermals "

    # delete old points
    Windpoint.destroy_all( ["igcfile_id = ?",igcfile.id])

    start_of_therm=0
    state=Constants::NOT_IN_THERMAL
    thermal_start=igcfile.objects[0]            # must be declared before case
    thermal_end=igcfile.objects[0]              # must be declared before case

    mams=17

    z=0

    igcfile.objects.each_with_index do |object,index|
      z=z+1

      case state

      when Constants::NOT_IN_THERMAL
        if object[:mams]<mams
          state=Constants::ENTER_THERMAL
          thermal_start=object.dup
        end

      when Constants::ENTER_THERMAL
        if object[:mams]<mams

          #debugger
          #puts "thermal_start " + thermal_start.inspect
          state=Constants::IN_THERMAL
        else
          state=Constants::NOT_IN_THERMAL
        end

      when Constants::IN_THERMAL
        if object[:mams]<mams
          state=Constants::IN_THERMAL
        else
          state=Constants::LEAVE_THERMAL
        end

      when Constants::LEAVE_THERMAL
        if object[:seq_secs]-thermal_start[:seq_secs]>120
          #puts "thermal_start2 " + thermal_start.inspect

          # go back 30 secs for end of thermal
          igcfile.objects[1..index].reverse_each {|item|
            if item[:seq_secs]<object[:seq_secs]-30
              thermal_end=item.dup
              break
            end
          }

          climb = (thermal_end[:baro_alt] - thermal_start[:baro_alt]).to_f/(thermal_end[:seq_secs] - thermal_start[:seq_secs]).to_f

          if climb > 0.2

            # wind direction is back from point 2 to point 1
            lon2 = thermal_start[:malon]
            lat2 = thermal_start[:malat]
            lon1 = thermal_end[:malon]
            lat1 = thermal_end[:malat]

            #            puts lon1.to_s + " " + lat1.to_s
            #            puts lon2.to_s + " " + lat2.to_s
            #            puts thermal_start[:baro_alt].to_s + " " + thermal_end[:baro_alt].to_s
            #            puts thermal_start[:seq_secs].to_s + " " + thermal_end[:seq_secs].to_s

            #d=(2*Math.asin(((Math.sin((lat1-lat2)/2))**2 + Math.cos(lat1)*Math.cos(lat2)*(Math.sin((lon1-lon2)/2))**2)**0.5)).abs
            #d=Math.acos(Math.sin(lat1)*Math.sin(lat2)+Math.cos(lat1)*Math.cos(lat2)*Math.cos(lon1-lon2))
            d=Math.acos(Math.sin(lat1)*Math.sin(lat2)+Math.cos(lat1)*Math.cos(lat2)*Math.cos(lon1-lon2))


            #           puts "A"
            #y = Math.sin(lon2-lon1) * Math.cos(lat2)
            #x = Math.cos(lat1)*Math.sin(lat2) -  Math.sin(lat1)*Math.cos(lat2)*Math.cos(lon2-lon1)
            #direction = Math.atan2(y,x)
            #            save =0
            #            puts d.to_s + " " + lat1.to_s + " " + lon1.to_s + " " + lat2.to_s + " " + lon2.to_s
            #
            #            if Math.sin(lon2-lon1)<0
            #              begin
            #                direction=Math.acos((Math.sin(lat2)-Math.sin(lat1)*Math.cos(d))/(Math.sin(d)*Math.cos(lat1)))
            #                rescue Exception=>e
            #                puts z.to_s
            #                puts d.to_s + " " + lat1.to_s + " " + lon1.to_s + " " + lat2.to_s + " " + lon2.to_s + "X"
            #                save=1
            #              end
            #            else
            #              direction=2*Constants::PI-Math.acos((Math.sin(lat2)-Math.sin(lat1)*Math.cos(d))/(Math.sin(d)*Math.cos(lat1)))
            #            end

            y = Math.sin(lon1-lon2) * Math.cos(lat2)
            x = (Math.cos(lat1)*Math.sin(lat2)) - (Math.sin(lat1)*Math.cos(lat2)*Math.cos(lon1-lon2))
            direction = (Math.atan2(y,x) + Constants::PI) % (2*Constants::PI)

            speed = d*Constants::RADIUS / (thermal_end[:seq_secs] - thermal_start[:seq_secs])

            #            puts thermal_start[:seq_secs].to_s + " " + thermal_end[:seq_secs].to_s + " " +
            #            (thermal_end[:seq_secs] - thermal_start[:seq_secs]).to_s[0,3] + " " +
            #            " dis " + (d*Constants::RADIUS).to_s[0,4] + " " +
            #            " climb " + climb.to_s[0,4] + " " +
            #            " dir " + direction.to_s[0,4] +
            #            " speed " + speed.to_s[0,4]

            w = Windpoint.new(:igcfile_id => igcfile.id,:speed => speed, :direction => direction, :climb => climb,
                              :altitude => thermal_start[:baro_alt], :dlat => thermal_start[:malat],
                              :dlon => thermal_start[:malon], :seq_secs => thermal_start[:seq_secs],
                              :altitude2 => thermal_end[:baro_alt], :dlat2 => thermal_end[:malat],
                              :dlon2 => thermal_end[:malon], :seq_secs2 => thermal_end[:seq_secs])
            w.save

          end

        end
        state=Constants::NOT_IN_THERMAL

      else
        puts "You just making it up!"
      end

    end
    #

    #puts " atan2(1,-1) " + Math.atan2(1,-1).to_s
    puts ""
  end


end

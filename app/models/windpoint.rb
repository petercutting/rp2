class Windpoint < ActiveRecord::Base
  belongs_to :igcfile

  def Windpoint.find_thermals(igcfile,objects)

    start_of_therm=0
    state=Constants::NOT_IN_THERMAL
    thermal_start={}            # must be declared before case

    objects.each_with_index do |object,index|

      case state
      when Constants::NOT_IN_THERMAL
        if object[:mams]<20
          state=Constants::ENTER_THERMAL
          thermal_start=object.dup
        end
      when Constants::ENTER_THERMAL
        if object[:mams]<20

          #debugger
          #puts "thermal_start " + thermal_start.inspect
          state=Constants::IN_THERMAL
        else
          state=Constants::NOT_IN_THERMAL
        end
      when Constants::IN_THERMAL
        if object[:mams]<20
          state=Constants::IN_THERMAL
        else
          state=Constants::LEAVE_THERMAL
        end
      when Constants::LEAVE_THERMAL
        if object[:seq_secs]-thermal_start[:seq_secs]>100
          #puts "thermal_start2 " + thermal_start.inspect
          puts "thermal start at " + thermal_start.inspect
          w = Windpoint.new(:igcfile_id => igcfile.id,
          :altitude => thermal_start[:baro_alt], :dlat => thermal_start[:dlat], :dlon => thermal_start[:dlon], :seq_secs => thermal_start[:seq_secs],
          :altitude2 => object[:baro_alt], :dlat2 => object[:dlat], :dlon2 => object[:dlon], :seq_secs2 => object[:seq_secs])
          w.save
        end
        state=Constants::NOT_IN_THERMAL
      else
        puts "You just making it up!"
      end

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

end

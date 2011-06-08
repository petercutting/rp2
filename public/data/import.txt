# load Rails
#require File.join(File.dirname(__FILE__), "..", "..", "config", "boot")
require File.join(File.dirname(__FILE__), "..", "..", "config", "environment")

require 'ar-extensions'
require 'ar-extensions/import/sqlite'

#gem install activerecord-import -v 0.2.0
# rake task?

RAD_PER_DEG = 0.017453293  #  PI/180
RADIUS = 6371 * 1000

class Import
  @objects = Array.new

  def import_igcfiles()
    num_recs=0
    dir="public/data"

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

    columns = [ :lat_lon, :baro_alt, :gps_alt, :enl, :seq_secs, :igcfile_id, :flat, :flon,:x,:y]

    sma=[]

    @objects = []
    num_recs=1 # to prevent divide by zero

    begin
      igcfile = Igcfile.new()
      igcfile.filename=file
      igcfile.save!
      rescue
      next
    end


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
        #Latitude        8 bytes           DDMMMMMN         Valid characters N, S, 0-9
        #Longitude       9 bytes           DDDMMMMME        Valid characters E,W, 0-9
        #Lat/Long - D D M Mm m m N D D D M M m m m E
        dd,mm,mmm,ns = a[2].scan(%r{(\d{2})(\d{2})(\d{3})(\w{1})}).flatten
        #puts dd +' ' + mm + ' ' + mmm + ' ' + ns
        #puts dd + ' ' + (mm.to_i/60 + ' ' + (mmm.to_i/1000)/60 + ' ' + ns
        flat = (dd.to_f + mm.to_f/60 + (mmm.to_f/1000)/60)*RAD_PER_DEG
        flat = - flat unless ns=='N'

        ddd,mm,mmm,ew = a[3].scan(%r{(\d{3})(\d{2})(\d{3})(\w{1})}).flatten
        flon = (ddd.to_f + mm.to_f/60 + (mmm.to_f/1000)/60)*RAD_PER_DEG
        flon = - flon unless ew=='E'

        # cartesian
        x = RADIUS * Math.cos(flat) * Math.cos(flon)
        y = RADIUS * Math.cos(flat) * Math.sin(flon)

        sma << [x.to_i,y.to_i]
        sma.shift unless sma.length < 5

        xa=0
        ya=0
        sma.each{|e|
          xa=xa+e[0]
          ya=ya+e[1]
        }
        if sma.length>1
          x=xa/sma.length
          y=ya/sma.length
        end

        @objects << [ a[2]+','+a[3],a[5].to_i,a[6].to_i,enl.to_i, time, igcfile.id,flat,flon,x.to_i,y.to_i]

        # last_time=time
      end
    end


    start = Time.now

    Igcpoint.import columns, @objects

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

  Rmeters * c     # delta in meters

  @distances["m"] = dMeters
end


puts "Starting..."
import = Import.new
import.import_igcfiles()



#db = SQLite3::Database.new('spam.db')
#spam, good = db.get_first_row("select spam,good from SPAMSTATS where phrase = ' '")
#db.execute("update SPAMSTATS set spam = ?, good = ? where phrase = ' '", spam, good)
#newspam, newgood = db.get_first_row("select spam, good from SPAMSTATS where phrase = ' '")
#assert_equal(spam, newspam)




#GDAL is very popular Open Source GIS kit, there are GDAL Ruby bindings. If you want map data,
#open street map is very useful. Combined plotting of OSM and the GPS will give pretty nice results.
#GDAL/OGR Api tutorial is here.

#Geokit & ym4r_gm

#http://community.activestate.com/product/komodo?page=3        gmaps example


#calculates a geodetic distance between two spatial points
def distance(start_lat, start_lon, other_lat, other_lon)
  latitude1 = start_lat.to_f * Math::PI/180 #in radian
  longitude1 = start_lon.to_f * Math::PI/180 #in radian
  latitude2 = other_lat.to_f * Math::PI/180 #in radian
  longitude2 = other_lon.to_f * Math::PI/180 #in radian
  cLa1 = Math.cos( latitude1 );
  x_A = RADIUS_EARTH * cLa1 * Math.cos( longitude1 )
  y_A = RADIUS_EARTH * cLa1 * Math.sin( longitude1 )
  z_A = RADIUS_EARTH * Math.sin( latitude1 );

  cLa2 = Math.cos( latitude2 );
  x_B = RADIUS_EARTH * cLa2 * Math.cos( longitude2 )
  y_B = RADIUS_EARTH * cLa2 * Math.sin( longitude2 )
  z_B = RADIUS_EARTH * Math.sin( latitude2 )

  #in meters
  distance = Math.sqrt( ( x_A - x_B ) * ( x_A - x_B ) + ( y_A - y_B ) * ( y_A - y_B ) + ( z_A - z_B ) * ( z_A - z_B ) )
end


#Two excellent discussions of altitude measurement may be found at:
#http://mtp.jpl.nasa.gov/notes/altitude/altitude.html
#http://mtp.jpl.nasa.gov/notes/altitude/AviationAltiudeScales.html



#1 Speed1 140 140
#2 Track1 192 192
#3 Speed2 112 112
#4 Track2 283 283
#5 Speed3 120 120
#6 Track3 20 20
#7 X1 =B1*SIN(PI()*(360-B2)/180)
#8 Y1 =B1*COS(PI()*(360-B2)/180)
#9 X2 =B3*SIN(PI()*(360-B4)/180)
#10 Y2 =B3*COS(PI()*(360-B4)/180)
#11 X3 =B5*SIN(PI()*(360-B6)/180)
#12 Y3 =B5*COS(PI()*(360-B6)/180)
#13 M1 =-1*(B9-B7)/(B10-B8 )
#14 B1 =(B8+B10)/2-B13*(B7+B9) / 2
#15 M2 =-1*(B11-B7)/(B12-B8 )
#16 B2 =(B8+B12)/2-B15*(B7+B11) / 2
#17 WX =(B14-B16)/(B15-B13)
#18 WY =B13*B17+B14
#19 Wind_Speed =SQRT(B17^2+B18^2) 20.6
#20 Wind_Direction =MOD(540-(180/PI()*ATAN2(B18,B17)),360) 314.8
#21 TAS =SQRT((B7-B17)^2+(B8-B18)^2) 130
#22 Heading_1 =MOD(540-(180/PI()*ATAN2(B18-B8,B17-B7)),360) 200
#23 Heading_2 =MOD(540-(180/PI()*ATAN2(B18-B10,B17-B9)),360) 287.8
#24 Heading_3 =MOD(540-(180/PI()*ATAN2(B18-B12,B17-B11)),360) 11.7


#GPLIGC

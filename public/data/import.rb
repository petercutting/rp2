
# load Rails
#require File.join(File.dirname(__FILE__), "..", "..", "config", "boot")
require File.join(File.dirname(__FILE__), "..", "..", "config", "environment")

require 'ar-extensions'
require 'ar-extensions/import/sqlite'

#gem install activerecord-import -v 0.2.0
# rake task?


class Import
  @@objects = []

  def import_igcfiles()
    num_recs=0
    dir="public/data"

    Igcfile.delete_all
    Igcpoint.delete_all

    @files = Dir.entries(dir)
    for file in @files
      if file != "." && file != ".."
        if file.to_s.downcase.match(".igc")
          start = Time.now
          num_recs = import_a_igcfile(dir + "/" + file.to_s)
          secs =  Time.now - start
          puts file.to_s + ' ' + num_recs.to_s + ' ' + (num_recs/secs).to_i.to_s
          STDOUT.flush
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

    columns = [ :lat, :lon, :baro_alt, :gps_alt, :enl]

    @@objects.clear
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

    # get I record
    b_extensions_struc=[:start,:finish,:mnemonic]
    b_extensions = []
    b_extensions2 = Hash.new
    fp.each_line do |line|
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
            b_extensions << [b[0],b[1],b[2]]
            #b_extensions2 << [:start => a[0], :finnish => b[1], :mnemonic => b[2]]
            b_extensions2[b[2]]=[:start => b[0], :finnish => b[1]]
          }
        end
        break
      end
      break
    end

    if b_extensions.length == 0
      puts 'No I record'
    end

    if b_extensions2['ENL'].nil?
      puts 'No ENL in I record'
    else
      puts b_extensions2['ENL'].inspect
    end


    fp.each_line do |line|
# 0(1)=rec, 1(6)=time, 2(8)=lat, 3(9)=lon, 4(1)=validity, 5(5)=baro_alt, 6(5)=gps_alt, 7(3)=fix_accuracy, 8(2)=num_satelites, 9(3)=enl

      a=line.unpack('a1a6a8a9a1a5a5a3a2a3')
      if a[0].to_s == 'B'

        num_recs=num_recs+1
        #        if time=0
        #          time=a[1]
        #        end

        if a[7].nil?
          a[7]='0'
        end
        if a[8].nil?
          a[8]='0'
        end
        if a[9].nil?
          a[9]='0'
        end
        #        puts a[2].to_s + ' - ' + a[4].to_s
        #        STDOUT.flush
        #        @@objects << [ a[2].to_s,a[3].to_s,a[5],a[6],a[9]]
        @@objects << [ a[2],a[3],a[5].to_i,a[6].to_i,a[9].to_i]

        if a[9].to_i>0
#          puts a[9]
        end
      end

    end

    #    Igcpoint.import objects
    #    Igcpoint.import  objects
    Igcpoint.import columns, @@objects

    fp.close
    num_recs
  end


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

puts "Starting..."
import = Import.new
import.import_igcfiles()



#db = SQLite3::Database.new('spam.db')
#spam, good = db.get_first_row("select spam,good from SPAMSTATS where phrase = ' '")
#db.execute("update SPAMSTATS set spam = ?, good = ? where phrase = ' '", spam, good)
#newspam, newgood = db.get_first_row("select spam, good from SPAMSTATS where phrase = ' '")
#assert_equal(spam, newspam)

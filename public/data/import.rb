
# load Rails
require File.join(File.dirname(__FILE__), "..", "..", "config", "boot")
require File.join(File.dirname(__FILE__), "..", "..", "config", "environment")

#require 'active_record'

#gem 'activerecord-import', '= 0.2.2'  # this is how to require a specific gem version
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



  #B0915235535648N01340869EA-006900049000
  #B0915355535648N01340870EA-007000049000
  #B091547 5535648 N 01340870 E A-007000049000

  #B103422 5535706N 01340750E A0003200037000016000000
  #B1034245535706N01340750EA0003100037000016000000
  #B1034265535706N01340750EA0003100037000012000000
  #B1038255535669N01339604EA0039000396000996000000

# 0=rec
# 1=time
# 2=lat
# 3=NS
# 4=lon
# 5=EW

  # relative X Y movement ENL curveing
  def import_a_igcfile(file)
    columns = [ :lat, :lon ]

    @@objects.clear
    num_recs=1 # to prevent divide by zero

    begin
      igcfile = Igcfile.new()
      igcfile.filename=file
      igcfile.save!
      rescue
      next
    end
    counter=0
    fp = File.open(file, "r")
    fp.each_line do |line|
      #      record = RT1.new(line)
      #      id = record[:tlid]
      #      @database[id] = record

      a=line.unpack('a1a6a7a1a8a1a14a3')
      if a[0].to_s == 'B'
        num_recs=num_recs+1

        #        puts a[2].to_s + ' - ' + a[4].to_s
        #        STDOUT.flush

        @@objects << [ a[2].to_s,a[4].to_s ]

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

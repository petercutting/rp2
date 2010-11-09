
# load Rails
require File.join(File.dirname(__FILE__), "..", "..", "config", "boot")
require File.join(File.dirname(__FILE__), "..", "..", "config", "environment")

require 'activerecord'
require 'activerecord-import'


#gem install activerecord-import -v 0.2.0
# rake task?


class Import

  def import_igcfiles()
    counter=0
    dir="public/data"

    Igcfile.delete_all
    Igcpoint.delete_all

    @files = Dir.entries(dir)
    for file in @files
      if file != "." && file != ".."
        if file.to_s.downcase.match(".igc")
          import_a_igcfile(dir + "/" + file.to_s)
        end
      end
      counter+=1
      puts counter.to_s + ' ' + file.to_s
      STDOUT.flush

    end
  end



  #B0915235535648N01340869EA-006900049000
  #B0915355535648N01340870EA-007000049000
  #B091547 5535648 N 01340870 E A-007000049000

  #B103422 5535706N 01340750E A0003200037000016000000
  #B1034245535706N01340750EA0003100037000016000000
  #B1034265535706N01340750EA0003100037000012000000
  #B1038255535669N01339604EA0039000396000996000000

  # relative X Y movement ENL curveing
  def import_a_igcfile(file)
    objects = []

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
        counter+=1
        #        puts counter.to_s + ' ' + a[1].to_s + ' - ' + a[2].to_s
        #        STDOUT.flush

        objects = Igcpoint.new(:lat => a[2].to_s)

      end

    end

    Igcpoint.import objects
    fp.close
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

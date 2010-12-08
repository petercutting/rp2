desc "Loads IGC files from specified directory (or .)"

# rake ligc3[.]
# rake ligc3[public/data]

task :ligc3, [:dir] => :environment do |t, args|
  args.with_defaults(:dir => "public/data")

  #  require 'ar-extensions'
  #  require 'ar-extensions/import/mysql'
  require 'find'

  #gem install activerecord-import -v 0.2.0


  puts File.dirname(__FILE__)
  #  @dir="#{args.dir}"
  #  puts @dir

  class Import

    def import_igcfiles(dir)
      puts 'directory is ' + dir
      num_recs=0

      Igcfile.delete_all
      Igcpoint.delete_all

      WalkDirs(dir)
      #STDOUT.flush

    end

    def WalkDirs(path)
      Find.find(path) do |entry|
        if File.file?(entry) and entry.to_s.downcase.match('.igc')
          #puts entry
          import_a_igcfile(entry)
        end
      end
    end


    def import_a_igcfile(path)
      start = Time.now

      columns = [ :lat_lon, :baro_alt, :gps_alt, :enl, :seq_secs, :igcfile_id, :rlat, :rlon, :x, :y]
      options = { :validate => false }
      save_obj=Hash.new
      sma=[]

      objects = []
      num_recs=1 # to prevent divide by zero
      counter=0

      begin
        igcfile = Igcfile.new()
        igcfile.filename=path
        igcfile.save!
        rescue
        #next
      end

      num_recs = Igc.import_igcfile(path)
      #          secs =  Time.now - start
      #          puts path.to_s + ' ' + num_recs.to_s + ' ' + (num_recs/secs).to_i.to_s
      num_recs
    end

  end

  puts "Starting..."
  import = Import.new
  import.import_igcfiles("#{args.dir}")

end




#[1, 2, 3, 4].inject(0) { |result, element| result + element } # => 10

#[1, 2, 3, 4, 5, 6].select { |element| element % 2 == 0 }.collect { |element| element.to_s } # => ["2", "4", "6"]

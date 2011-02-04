desc "Loads IGC files from specified directory (or .)"

# rake ligc3[.]
# rake ligc3[public/data]
# rake ligc3["C:/Documents and Settings/Peter Cutting/My Documents/soaring/logs/IGC/RST/IGC_files_2009-09-30"]
# rake ligc3["C:/Documents and Settings/Peter Cutting/My Documents/soaring/logs/IGC/RST/test"]

task :ligc3, [:proc_version,:dir] => :environment do |t, args|
  args.with_defaults(:dir => "public/data")
  args.with_defaults(:proc_version => 0)

  #  require 'ar-extensions'
  #  require 'ar-extensions/import/mysql'
  require 'find'

  #gem install activerecord-import -v 0.2.0



  puts File.dirname(__FILE__)
  puts proc_version
  #  @dir="#{args.dir}"
  #  puts @dir

  class Import

    def process_igcfiles(dir)
      puts 'directory is ' + dir
      num_recs=0

#      Igcfile.destroy_all
#      Igcpoint.destroy_all
#      Windpoint.destroy_all

      WalkDirs(dir)
      #STDOUT.flush
    end


    def WalkDirs(path)
      Find.find(path) do |entry|
        if File.file?(entry) and entry.to_s.downcase.match('.igc$')
          #puts entry
          process_igcfile(entry)
        end
      end
    end


    def process_igcfile(path)

      filename=path.split("/").last

      start = Time.now
      #puts "processing " + path
      num_recs=1 # to prevent divide by zero

      #      begin
      #        puts "deleting " + filename
      #        Igcfile.destroy_all( ["filename = ?",filename])
      #      rescue
      #      end

      #debugger
      begin
        puts "Looking in DB for " + filename
        @igcfile = Igcfile.find_by_filename!(filename) # ! enables a recordnotfound exception

        if @igcfile.proc_version.to_i < Constants::PROC_VERSION.to_i
          puts "Old version " + @igcfile.proc_version.to_s
          raise ActiveRecord::RecordNotFound
        end

        rescue ActiveRecord::RecordNotFound => ex
        #puts ex.message
        #puts ex.backtrace.join("\n")
        Igcfile.destroy_all( ["filename = ?",filename])
        @igcfile = Igcfile.new(:path => path, :filename => filename, :proc_version => Constants::PROC_VERSION)
        @igcfile.save
        @objects = Igcfile.import(path)
        Windpoint.find_thermals(@igcfile,@objects)

#        @windpoints = Windpoint.find(:all,:order => "seq_secs DESC",:conditions => {
#          :igcfile_id  => @igcfile.id })

        rescue Exception => ex
        puts "Generic " + ex.message

      end

      #      puts "SAVING " + filename
      #      igcfile = Igcfile.new( :filename => filename, :path => path)
      #      igcfile.save

      #puts igcfile.inspect
      #      objects=[]
      #      objects = Igcfile.import(path)
      #      Windpoint.find_thermals(igcfile,objects)

      seconds = Time.now - start
      #      puts filename + ' ' + @objects.count.to_s + ' ' + (@objects.count/seconds).to_i.to_s
      STDOUT.flush

    end

  end

  puts "Starting..."
  import = Import.new
  import.process_igcfiles("#{args.dir}")

end


#    def process_igcfile(path)
#
#      filename=path.split("/").last
#
#      start = Time.now
#      #puts "processing " + path
#      num_recs=1 # to prevent divide by zero
#
#      begin
#        #puts "deleting " + filename
#        Igcfile.destroy_all( ["filename = ?",filename])
#      rescue
#      end
#
#
#      @objects = Igcfile.import(path)
#
#      begin
#        @igcfile = Igcfile.find_by_filename!(filename) # ! enables a recordnotfound exception
#        rescue Exception => ex
#        puts ex.message
#        puts filename
#        #puts ex.backtrace.join("\n")
#        @igcfile = Igcfile.new(:path => path, :filename => filename)
#        @igcfile.save
#        Windpoint.find_thermals(@igcfile,@objects)
#      end
#
#      #@windpoints = @igcfile.windpoint.find_all()
#      @windpoints = Windpoint.find(:all,:order => "seq_secs DESC",:conditions => {
#        :igcfile_id  => @igcfile.id })
#
#      @windpoints.each {|wp|
#        dlon_diff=wp[:dlon]-@centre[0].to_f
#        dlat_diff=wp[:dlat]-@centre[1].to_f
#
#        wp[:dlon_centred]=wp[:dlon]-dlon_diff
#        wp[:dlat_centred]=wp[:dlat]-dlat_diff
#        wp[:dlon2_centred]=wp[:dlon2]-dlon_diff
#        wp[:dlat2_centred]=wp[:dlat2]-dlat_diff
#      }
#
#
#
#      puts "SAVING " + filename
#      igcfile = Igcfile.new( :filename => filename, :path => path)
#      igcfile.save
#
#      #puts igcfile.inspect
#      objects=[]
#      objects = Igcfile.import(path)
#      Windpoint.find_thermals(igcfile,objects)
#
#      seconds = Time.now - start
#      puts filename + ' ' + objects.count.to_s + ' ' + (objects.count/seconds).to_i.to_s
#      STDOUT.flush
#
#    end
#
#  end
#
#  puts "Starting..."
#  import = Import.new
#  import.process_igcfiles("#{args.dir}")
#
#end




#[1, 2, 3, 4].inject(0) { |result, element| result + element } # => 10

#[1, 2, 3, 4, 5, 6].select { |element| element % 2 == 0 }.collect { |element| element.to_s } # => ["2", "4", "6"]

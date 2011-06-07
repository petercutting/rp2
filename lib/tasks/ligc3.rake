desc "Loads IGC files from specified directory (or .)"

# rake ligc3[c:/Users/peter/workspace_rails/igc,0]
# rake ligc3[c:/Users/peter/workspace_rails/igcsmall,0]

# rake ligc3[.,0]
# rake ligc3[public/data,0]
# rake ligc3[public/data/NewFolder,0]
# rake ligc3["C:\Documents and Settings/Peter Cutting/My Documents/soaring/logs",0]
# rake ligc3["C:\Documents and Settings\cuttingp\My Documents\soaring\logs",0]
# rake ligc3["C:\Documents and Settings\cuttingp\My Documents\soaring\logs",0]
# rake ligc3["C:/Documents and Settings/Peter Cutting/My Documents/soaring/logs/IGC/RST/IGC_files_2009-09-30",0]
# rake ligc3["C:/Documents and Settings/Peter Cutting/My Documents/soaring/logs/IGC/RST/test",0]

task :ligc3, [:dir,:proc_version] => :environment do |t, args|
  #debugger does not seem to work in rake tasks
  args.with_defaults(:dir => "public/data")
  args.with_defaults(:proc_version => 0)

  #  require 'ar-extensions'
  #  require 'ar-extensions/import/mysql'
  require 'find'

  #gem install activerecord-import -v 0.2.0


  puts "script dir " + File.dirname(__FILE__)
  #puts proc_version
  #  @dir="#{args.dir}"
  #  puts @dir
  #  print "B "
  #  $stdout.sync     # only need to be done once
  #  $stdout.flush

  class Import

    def process_igcfiles(dir,proc_version)
      debugger
      if proc_version == 0
        begin
          proc_version = Igcfile.maximum('proc_version') + 1
          rescue Exception=>e
          proc_version = 0
        end

      end

      puts 'directory is ' + dir
      num_recs=0

      Igcfile.destroy_all
      Igcpoint.destroy_all
      Windpoint.destroy_all

      WalkDirs(dir,proc_version)
    end


    def WalkDirs(path,proc_version)
      puts "look in " + path
      Find.find(path) do |entry|
        #puts entry
        if File.file?(entry) and entry.to_s.downcase.match('.igc$')
          process_igcfile(entry,proc_version)
        end
      end
    end


    def process_igcfile(path,proc_version)

      filename=path.split("/").last

      start = Time.now
      num_recs=1 # to prevent divide by zero

      #      begin
      #        puts "deleting " + filename
      #        Igcfile.destroy_all( ["filename = ?",filename])
      #      rescue
      #      end

      #debugger

      @igcfile = Igcfile.get(path,proc_version)

      seconds = Time.now - start
      #      puts filename + ' ' + @objects.count.to_s + ' ' + (@objects.count/seconds).to_i.to_s
      STDOUT.flush

    end

  end

  puts "Starting..."
  #debugger
  import = Import.new

  import.process_igcfiles("#{args.dir}","#{args.proc_version}".to_i)

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

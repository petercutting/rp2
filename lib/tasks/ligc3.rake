desc "Loads IGC files from specified directory (or .)"

# rake ligc3[.]
# rake ligc3[public/data]
# rake ligc3["C:/Documents and Settings/Peter Cutting/My Documents/soaring/logs/IGC/RST/IGC_files_2009-09-30"]

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

    def process_igcfiles(dir)
      puts 'directory is ' + dir
      num_recs=0

      #Igcfile.destroy_all
      #Igcpoint.destroy_all
      #Windpoint.destroy_all

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
      start = Time.now
      #puts "processing " + path
      num_recs=1 # to prevent divide by zero

      begin
        #puts "deleting " + path.split("/").last
        Igcfile.destroy_all( ["filename = ?",path.split("/").last])
        rescue
      end

      igcfile = Igcfile.new(:path => path, :filename => path.split("/").last)
      igcfile.save

      #puts igcfile.inspect
      objects=[]
      objects = Igcfile.import(path)
      Windpoint.find_thermals(igcfile,objects)

      seconds = Time.now - start
      puts path.split("/").last + ' ' + objects.count.to_s + ' ' + (objects.count/seconds).to_i.to_s
      STDOUT.flush

    end

  end

  puts "Starting..."
  import = Import.new
  import.process_igcfiles("#{args.dir}")

end




#[1, 2, 3, 4].inject(0) { |result, element| result + element } # => 10

#[1, 2, 3, 4, 5, 6].select { |element| element % 2 == 0 }.collect { |element| element.to_s } # => ["2", "4", "6"]

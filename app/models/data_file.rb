class DataFile < ActiveRecord::Base
  def self.save(upload)
    debugger
    puts upload.inspect
    name =  upload.original_filename
    directory = "public/data"
    # create the file path
    path = File.join(directory, name)
    # write the file
    File.open(path, "wb") do |f|
      while buff = upload.read(4096)
        f.write(buff)
      end
    end
  end
end
